import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:foor_ordering/admin/admin_request_details.dart';
import 'package:foor_ordering/intro.dart';
import 'package:image_picker/image_picker.dart';


import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'dart:math';

class AdminFirstScreen extends StatefulWidget {
  
  final admin_id;
  AdminFirstScreen(this.admin_id);
  @override
  _AdminFirstScreenState createState() => _AdminFirstScreenState();
}

class _AdminFirstScreenState extends State<AdminFirstScreen> {
  final _formKey = GlobalKey<FormState>();


  String search_item='';
  int container_index=1;

  String name;
  double price;
  String type="Starter";
  String veg="veg";
  File _image;
  var img_path;
  int status = 2;
  bool expanded = true;
  var allData;
  bool loading = false;
  int gender=1;
  bool isVeg=true;
  bool isoffline=false;


  /*
  * 1 male
  * 2 female
  */


  Future<String> uploadFile(File image) async {
    String downloadURL;
    String postId = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref =
    FirebaseStorage.instance.ref().child("images").child("$name.jpg");
    await ref.putFile(image);
    downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }
  bool inProcess;
  void selectImageFromCamera() async {
    final picker = ImagePicker();
    setState(() {
      inProcess = true;
    });
    final imageFile =
    await picker.getImage(source: ImageSource.camera, imageQuality: 50);

    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
      });
    }
    setState(() {
      inProcess = false;
    });
  }

  void selectImageFromGallery() async {
    final picker = ImagePicker();
    setState(() {
      inProcess = true;
    });
    final imageFile =
    await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
      });
    }
    setState(() {
      inProcess = false;
    });
  }
  final Connectivity _connectivity = Connectivity();
  StreamSubscription< ConnectivityResult > _connectivitySubscription;

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_UpdateConnectionState);
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }


  Future< void > initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      setState(() {
        if(result==ConnectivityResult.none){
          isoffline=true;
        }
        else {
          isoffline=false;
        }
      });

    } on Exception catch (e) {
      print("Error Occurred: ${e.toString()} ");
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _UpdateConnectionState(result);
  }

  Future<void> _UpdateConnectionState(ConnectivityResult result) async {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      showStatus(result, true);
    } else {
      showStatus(result, false);
    }
  }

  void showStatus(ConnectivityResult result, bool status) {
    if(status){
      setState(() {
        isoffline=false;
      });
    }
    else {
      setState(() {
        isoffline=true;
      });
    }


  }
  Widget dialogBox() {
    return AlertDialog(
      title: Text(
        'WeChat',
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      content: Text(
        'Choose an image from',
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      actions: [
        FlatButton(
          textColor: Colors.black,
          onPressed: () {
            selectImageFromCamera();
            Navigator.pop(context);
          },
          child: Text(
            'CAMERA',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        FlatButton(
          textColor: Colors.black,
          onPressed: () {
            selectImageFromGallery();
            Navigator.pop(context);
          },
          child: Text(
            'GALLERY',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  int index = 0;

  void onTap(int index) {
    setState(() {
      index = index;
    });
  }
  String selectedValue = "Starter";

  List<DropdownMenuItem<String>> get dropdownItems{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Starter"),value: "Starter"),
      DropdownMenuItem(child: Text("Fast Food"),value: "Fast Food"),
      DropdownMenuItem(child: Text("Main Course"),value: "Main Course"),
      DropdownMenuItem(child: Text("Desert"),value: "Desert"),
    ];
    return menuItems;
  }



  void _trySubmit(String name, double price) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if(_image==null) {
      final snackBar = SnackBar(
        elevation: 10,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        // shape: ShapeBorder.,
        backgroundColor:
        Colors.brown[300].withOpacity(0.7),
        content: Container(
          height: 50,
          width: 500,
          decoration: BoxDecoration(
            // color: Colors.green[200],
            // border: Border.all(
            //   // color: Colors.red,
            //     width: 1,
            //     color: Colors.black
            // ),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        "asset/warning-logo.png"),
                    fit: BoxFit.contain,
                  ),
                  shape: BoxShape.rectangle,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "WARNING !",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    "This food item is already\n added to the cart !",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),

        action: SnackBarAction(
          label: 'Okay',
          textColor: Colors.black,
          onPressed: () {
            // Some code to undo the change.
            // Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar);
    }

    if (isValid && _image != null) {
      _formKey.currentState.save();
      var Item_id=DateTime.now();
      var img_path1 = await uploadFile(_image);

      setState(() {
        img_path = img_path1.toString();
      });
      FirebaseFirestore.instance.collection('admin_details_items').add({
        'admin_details_items_key':widget.admin_id.toString(),
          'item_id': Item_id.toString(),
          'image': img_path,
          'name': name,
          'price': price,
          'ratings': 2,
          'type': type,
          'veg': veg,
        'user_count':1,

      });
      // signUp(email: _userEmail, password: _userPassword);
    }
  }
  Future<void> getData() async {
    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection('admin_details');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    CollectionReference _collectionRef1 =
    FirebaseFirestore.instance.collection('admin_details_items');
    QuerySnapshot querySnapshot1 = await _collectionRef.get();
    final allData1 = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(allData1);
  }

  Widget Add()  {



    return Scaffold(
   
      body: Center(
        child: Card(
          color: Colors.yellow[100],
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.orange[100],
                      backgroundImage:
                      _image != null ? FileImage(_image) : null,
                    ),
                    FlatButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => dialogBox()));
                      },
                      icon: Icon(Icons.image , color: Colors.orange[200],),
                      label: Text('Food Image'),
                      textColor: Colors.black,
                    ),
                  
                    Padding(
                      padding:
                      EdgeInsets.only( top: 30, bottom: 10),
                      child: TextFormField(
                        key: ValueKey('name'),
                        validator: (value) {
                          if (value.isEmpty || value.length < 4) {
                            return 'Please enter an valid Food name';
                          }
                          return null;
                        },

                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              "asset/food-item-logo.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.fill,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'Enter Food name',
                        ),
                      ),
                    ),
                   
                    Padding(
                      padding:
                      EdgeInsets.only( bottom: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(),
                        key: ValueKey('price'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter price';
                          }
                          return null;
                        },

                        onChanged: (value) {
                          setState(() {
                            price = double.parse(value);
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              "asset/price-tag-logo.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.fill,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'Enter Price',
                        ),
                      ),
                    ),
                   
                    Padding(
                      padding: EdgeInsets.only(top: 20,left: 15),
                      child: Row(children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // gender = 1;
                              isVeg=true;
                              veg="veg";
                            });
                          },
                          child: Container(
                            // height: 85,
                            // width: 85,
                            decoration: BoxDecoration(
                              border: gender == 1
                                  ? Border.all(
                                  color: Colors.orangeAccent[200], width: 4)
                                  : Border.all(color: Colors.white, width: 0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "asset/veg-logo.jpg"
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                    shape: BoxShape.rectangle),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // gender = 2;
                              isVeg = false;
                              veg = "non-veg";
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: gender == 2
                                  ? Border.all(
                                  color: Colors.orangeAccent[200], width: 4)
                                  : Border.all(color: Colors.white, width: 0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    // borderRadius: BorderRadius.circular(15),
                                    // border: Border.all(color: Colors.yellow[300]),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        "asset/non-veg-logo.jpg",
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                    shape: BoxShape.rectangle),
                              ),
                            ),
                          ),
                        ),
                      ],
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    
                    SizedBox(height: 20,),
                    DropdownButtonFormField(
                      icon: Icon(Icons.fastfood_sharp),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow[200], width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow[200], width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.orange[100],
                        ),
                        dropdownColor: Colors.orange[100],
                      style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black , fontSize: 20),
                        value: selectedValue,

                        elevation: 5,
                        onChanged: (String newValue){
                          setState(() {
                            selectedValue = newValue;
                            type=newValue;
                          });
                        },
                        items: dropdownItems

                    ),
                    SizedBox(
                      height: 12,
                    ),
                    ButtonTheme(
                      minWidth: 200.0,
                      height: 50.0,

                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.orange[100],
                        onPressed: () async {
                          if (_image == null) {
                           
                            final snackBar = SnackBar(
                              elevation: 10,
                              duration: Duration(seconds: 5),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(10),
                              // shape: ShapeBorder.,
                              backgroundColor: Colors.brown[300].withOpacity(0.7),
                              content: Container(
                                height: 50,
                                width: 500,
                                decoration: BoxDecoration(
                                  
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage("asset/warning-logo.png"),
                                          fit: BoxFit.contain,
                                        ),
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text("WARNING !" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20 , color: Colors.black),),
                                        SizedBox(height: 3,),
                                        Text("Upload an image of Food item !" , style: TextStyle(fontSize: 10 , color: Colors.black),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              action: SnackBarAction(
                                textColor: Colors.black,

                                label: 'Okay ' ,
                                onPressed: () {

                         
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } else if(_formKey.currentState.validate()==false) {
                            final snackBar = SnackBar(
                              elevation: 10,
                              duration: Duration(seconds: 5),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(10),
                              // shape: ShapeBorder.,
                              backgroundColor: Colors.red[300].withOpacity(0.7),
                              content: Container(
                                height: 52,
                                width: 500,
                                decoration: BoxDecoration(
                                  
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage("asset/wrong-logo.png"),
                                          fit: BoxFit.contain,
                                        ),
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text("OOPS !" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20 , color: Colors.black),),
                                        SizedBox(height: 3,),
                                        Text("Please provide necessary\n information !" , style: TextStyle(fontSize: 10 , color: Colors.black),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              action: SnackBarAction(
                                label: 'Okay',
                                textColor: Colors.black,
                                onPressed: () {
                                  
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();

                                },
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          else {
                            _trySubmit(name, price);
                            final snackBar = SnackBar(
                              elevation: 10,
                              duration: Duration(seconds: 5),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(10),
                              // shape: ShapeBorder.,
                              backgroundColor: Colors.green[300].withOpacity(0.7),
                              content: Container(
                                height: 50,
                                width: 500,
                                decoration: BoxDecoration(
                                  
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage("asset/right-symbol.png"),
                                          fit: BoxFit.contain,
                                        ),
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text("SUCCESS !" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20 , color: Colors.black),),
                                        SizedBox(height: 3,),
                                        Text("Food information is \nsaved Successfully !" , style: TextStyle(fontSize: 10 , color: Colors.black),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              action: SnackBarAction(
                                label: 'Okay',
                                textColor: Colors.black,
                                onPressed: () {

                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            _formKey.currentState.reset();
                            setState(() {
                              _image=null;
                            });
                          }
                        },
                        // child: Text('Add'),
                        child: Text(
                          "ADD",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget FoodList() {
    return Column(
      children: <Widget>[

        Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 10),
          child: TextFormField(
            key: ValueKey('searched item'),
            onChanged: (value) {
              setState(() {
                search_item = value;
                if (search_item.isNotEmpty && search_item != null)
                  container_index = 6;
                else
                  container_index = 1;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/128/49/49116.png",
                  width: 15,
                  height: 15,
                  fit: BoxFit.fill,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: 'Enter your fav food',
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 20.0),
          height: 50.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 1;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: container_index == 1
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/2082/2082045.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "All Items",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 2;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: container_index == 2
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/128/3823/3823394.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Starters",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 3;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: container_index == 3
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/128/1037/1037762.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Fast Food",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 4;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 135.0,
                    decoration: BoxDecoration(
                      color: container_index == 4
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/926/926292.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "MainCourse",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 5;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: container_index == 5
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/3157/3157358.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Desert",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
            child: StreamBuilder<QuerySnapshot>(

                stream: ((search_item == null ||
                    search_item.length == 0 )&&
                    container_index == 1)
                    ? FirebaseFirestore.instance
                    .collection("admin_details_items")
                    .where('admin_details_items_key',
                    isEqualTo: widget.admin_id.toString())
                    .snapshots()
                    : (container_index == 2
                    ? FirebaseFirestore.instance
                    .collection("admin_details_items")
                    .where('admin_details_items_key',
                    isEqualTo: widget.admin_id.toString())
                    .where('type', isEqualTo: 'Starter')
                    .snapshots()
                    : (container_index == 3
                    ? FirebaseFirestore.instance
                    .collection("admin_details_items")
                    .where('admin_details_items_key',
                    isEqualTo: widget.admin_id.toString())
                    .where('type', isEqualTo: 'Fast Food')
                    .snapshots()
                    : (container_index == 4
                    ? FirebaseFirestore.instance
                    .collection("admin_details_items")
                    .where('admin_details_items_key',
                    isEqualTo: widget.admin_id.toString())
                    .where('type', isEqualTo: 'Main Course')
                    .snapshots()
                    : (container_index == 5
                    ? FirebaseFirestore.instance
                    .collection("admin_details_items")
                    .where('admin_details_items_key',
                    isEqualTo:
                    widget.admin_id.toString())
                    .where('type', isEqualTo: 'Desert')
                    .snapshots()
                    : FirebaseFirestore.instance
                    .collection("admin_details_items")
                    .where('admin_details_items_key',
                    isEqualTo:
                    widget.admin_id.toString())
                    .where('name',
                    isGreaterThanOrEqualTo: search_item)
                    .where('name',
                    isLessThan: search_item + 'z')
                    .snapshots())))),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return GridView.builder(

                      itemBuilder: (context, index) {
                        return Container(

                          height: 400,
                          width: 400,
                          child: Card(
                            // color: Colors.[200],
                            elevation: 12,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: <Widget>[
                                    IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("admin_details_items")
                                              .where("item_id",
                                              isEqualTo: snapshot.data
                                                  .docs[index]['item_id'])
                                              .get()
                                              .then((value) {
                                            value.docs.forEach((element) {
                                              FirebaseFirestore.instance
                                                  .collection(
                                                  "admin_details_items")
                                                  .doc(element.id)
                                                  .delete()
                                                  .then((value) {
                                                print("Success!");
                                              });
                                            });
                                          });
                                        }),
                                  ],
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.green[500],
                                  radius: 50,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(snapshot.data
                                        .docs[index]['image']), //NetworkImage
                                    radius: 50,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      snapshot.data.docs[index]['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    SizedBox(width: 10,),
                                    snapshot.data.docs[index]['veg'] == "veg"
                                    // snapshot.data.docs[index]['veg'] == true
                                        ? Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage("asset/veg-logo.jpg"),
                                          fit: BoxFit.contain,
                                        ),
                                        shape: BoxShape.rectangle,
                                      ),
                                    )
                                        : Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage("asset/non-veg-logo.jpg"),
                                          fit: BoxFit.contain,
                                        ),
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                    '\u{20B9}${snapshot.data.docs[index]['price']}' , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),),
                              ],
                            ),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2 / 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: snapshot.data.docs.length,
                    );
                  }
                })),
      ],
    );
  }

  Widget Requests() {




    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("user_requests").where('restaurant_id', isEqualTo: widget.admin_id)
            .snapshots(),
        builder: (context, snapshot) {
          // print(snapshot.data.docs[0]['user_id'].toString());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return snapshot.data.docs.length == 0
                ? Padding(
              padding: EdgeInsets.only(top: 300, left: 30),
              child: Container(
                height: 120,
                width: 310,
                child: Text(
                  "No Requests have been made yet !",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            )
                : ListView.builder(
              itemBuilder: (context, index) {
                // fetchData(snapshot.data.docs[index]['restaurant_id']);

                return !snapshot.hasData
                    ? Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Text("No Requests yes !"),
                    ))
                    : GestureDetector(
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>AdminRequestDetails(widget.admin_id,snapshot.data.docs[index]['request_id'])
                    ));
                  },
                      child: Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow[200],
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black54.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0,
                                1), // changes position of shadow
                          ),
                        ],
                        borderRadius:
                        BorderRadius.all(Radius.circular(15)),
                      ),
                      height:
                      expanded == true ? 4 * 70.0 + 50 : 230,
                      width: 500,
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        snapshot.data.docs[index]
                                        ['image']),
                                    backgroundColor:
                                    Colors.orange[200],
                                    radius: 50,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    snapshot.data.docs[index]
                                    ['name'],
                                    style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "asset/terms-and-conditions.png"),
                                        fit: BoxFit.contain,
                                      ),
                                      shape: BoxShape.rectangle,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  snapshot.data.docs[index]['status']  == 1
                                      ? Text(
                                    "Pending",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        Colors.orange),
                                  )
                                      : (snapshot.data.docs[index]['status']  == 3
                                      ? Text(
                                    "Rejected",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                        color:
                                        Colors.red),
                                  )
                                      : (snapshot.data.docs[index]['status'] == 2
                                      ? Text("Accepted",
                                      style: TextStyle(
                                          fontSize:
                                          20,
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          color: Colors
                                              .green))
                                      : Text(
                                    "Timed Out",
                                    style: TextStyle(
                                        fontSize:
                                        20,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                        color: Colors
                                            .grey),
                                  )))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Text(
                                    "Grand total",
                                    style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // Text("value"),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                "asset/rupee-symbol.png"),
                                            fit: BoxFit.contain,
                                          ),
                                          shape:
                                          BoxShape.rectangle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '${snapshot.data.docs[index]['total']}',
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      print("nach meri rani");
                                      expanded = !expanded;
                                      print(expanded);
                                    });
                                  },
                                  icon: Icon(expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more))
                            ],
                          ),

                          expanded
                              ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 4),
                            height: min(4 * 20.0 + 10, 100),
                            // height: ,
                            child: ListView.builder(
                              itemBuilder: (context, idx) {
                                return Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceEvenly,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Text(
                                          '${snapshot.data.docs[index]['food_name_list'][idx]}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .end,
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceEvenly,
                                      children: <Widget>[
                                        Row(
                                          children: <
                                              Widget>[
                                            Text(
                                              '${snapshot.data.docs[index]['count_list'][idx]} X',
                                              style:
                                              TextStyle(
                                                fontSize:
                                                18,
                                                color: Colors
                                                    .grey,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              height: 30,
                                              width: 30,
                                              decoration:
                                              BoxDecoration(
                                                image:
                                                DecorationImage(
                                                  image: AssetImage(
                                                      "asset/rupee-symbol.png"),
                                                  fit: BoxFit
                                                      .contain,
                                                ),
                                                shape: BoxShape
                                                    .rectangle,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '${snapshot.data.docs[index]['per_item_price_list'][idx]}',
                                              style:
                                              TextStyle(
                                                fontSize:
                                                18,
                                                color: Colors
                                                    .grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                              itemCount: snapshot
                                  .data
                                  .docs[index]['count_list']
                                  .length,
                              // itemCount: allData[index]['food_name_list'].length,
                            ),
                          )
                              : SizedBox(
                            height: 0,
                          ),
                        ],
                      ),
                  ),
                ),
                    );
              },
              itemCount: snapshot.data.docs.length,
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return isoffline ? Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "asset/no-internet.png"),
                  fit: BoxFit.contain,
                ),
                shape: BoxShape.rectangle,
              ),
            ),
            SizedBox(height: 20,),
            Text("NO INTERNET" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),),
            SizedBox(height: 20,),
            Text("Turn on your internet connection in order to continue !" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 10),),
          ],
        ),
      ),
    ):Scaffold(
      backgroundColor: Colors.orange[100],
      appBar: AppBar(
        title: Text('Admin panel'),
        backgroundColor: Colors.orange[200],
        actions: [
          GestureDetector(
            onTap: (){
              FirebaseAuth.instance.signOut();
              Navigator.push(context,MaterialPageRoute(builder: (context)=>Intro()));
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://cdn-icons-png.flaticon.com/128/1574/1574351.png"),
                  fit: BoxFit.contain,
                ),
                shape: BoxShape.rectangle,
              ),
            ),
          ),
        ],
      ),
      body: index == 0 ? FoodList() : (index == 1 ? Add() : Requests()),
      bottomNavigationBar: FancyBottomNavigation(
        // barBackgroundColor: Colors.orange[200],
        initialSelection: index,
        tabs: [
          TabData(

              iconData: Icons.fastfood,
              title: "Food List"),
          TabData(

              iconData: Icons.add_circle_rounded,
              title: "Add Item"),
          // TabData(iconData: Icons.perm_identity_outlined, title: "Profile"),
          TabData(

              iconData: Icons.history,
              title: "Requests"),

        ],
        circleColor: Colors.yellow[700],
        inactiveIconColor: Colors.yellow[700],
        onTabChangedListener: (position) {
          setState(() {
            index = position;
          });
        },
      ),
    );
  }
}
