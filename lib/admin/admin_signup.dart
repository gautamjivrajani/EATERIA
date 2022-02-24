import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'admin_login.dart';
import 'package:intl/intl.dart';
import 'admin_first_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_format/date_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:email_auth/email_auth.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isoffline=false;
  var _isLogin = false;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  var _userConfirmPass = '';
  var _verifyotp = '';
  var userAddress = '';
  final otpController = new TextEditingController();
  var code1;
  bool submitValid = false;
  EmailAuth emailAuth;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription< ConnectivityResult > _connectivitySubscription;



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
  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat.yMd().format(DateTime.now());
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_UpdateConnectionState);
    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
    _timeController1.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
    super.initState();
    emailAuth = new EmailAuth(
      sessionName: "EATERIA",
    );
  }

  File _image;
  bool inProcess;
  String img_path;
  var adminId;

  void _trySubmit(String _userEmail, String _userPassword, String setStartTime1,
      String setEndTime1) {
    //  snackbar which shows image is null.....//
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

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
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                    "Please upload an image",
                    style: TextStyle(fontSize: 10, color: Colors.black),
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
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (setStartTime1 == null) {
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
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                    "Please set an Opening Time !",
                    style: TextStyle(fontSize: 10, color: Colors.black),
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
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (setEndTime1 == null) {
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
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                    "Please set a Closing Time",
                    style: TextStyle(fontSize: 10, color: Colors.black),
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
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (isValid && _image != null) {
      _formKey.currentState.save();
      adminId = DateTime.now();
      signUp(email: _userEmail, password: _userPassword);
    }
  }

  final DBRef = FirebaseDatabase.instance.reference().child('Users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;
  final databaseRef = FirebaseDatabase.instance.reference();

  double _height;
  double _width;

  String setStartTime;
  String setEndTime;
  bool _isLoad = false;
  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _timeController1 = TextEditingController();
  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        setStartTime = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
        setStartTime = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  Future<Null> _selectTime1(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        setEndTime = _time;
        _timeController1.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
        setEndTime = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  Future signUp({String email, String password}) async {
    try {
      setState(() {
        _isLoad = true;
      });

      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      var img_path1 = await uploadFile(_image);

      setState(() {
        img_path = img_path1.toString();
      });
      if (img_path != null) {
        FirebaseFirestore.instance.collection('admin').add({
          'email': _userEmail,
          'name': _userName,
          'img_path': img_path,
          'admin_key': adminId.toString(),
        });
        FirebaseFirestore.instance.collection('admin_details').add({
          'admin_details_key': adminId.toString(),
          'email': _userEmail,
          'image': img_path,
          'name': _userName,
          'password': _userPassword,
          'start': setStartTime,
          'end': setEndTime,
          'userAddress': userAddress,

          // 'items': {},
          // 'requests': {},
        });
      }
      setState(() {
        _isLoad = false;
      });
      setState(() {
        _isLogin = true;
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AdminFirstScreen(adminId)));

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> uploadFile(File image) async {
    String downloadURL;
    String postId = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref =
        FirebaseStorage.instance.ref().child("images").child("$_userEmail.jpg");
    await ref.putFile(image);
    downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

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

  Widget dialogBox() {
    return AlertDialog(
      title: Text(
        'EATERIA',
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

  @override
  Widget build(BuildContext context) {
    return _isLoad == true
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            ),
          )
        : (_isLogin
            ? AdminFirstScreen(DateTime.now())
            : Scaffold(
                backgroundColor: Colors.white,
                body:isoffline ? Center(
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
                ): SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 200,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(45)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.yellow[100],
                                  Colors.orange[500]
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.yellow[600],
                                backgroundImage:
                                    _image != null ? FileImage(_image) : null,
                              ),
                              FlatButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => dialogBox()));
                                },
                                icon: Icon(Icons.image),
                                label: Text(
                                  'Add  a Restaurant Image',
                                  style: TextStyle(fontSize: 13),
                                ),
                                textColor: Colors.black,
                              ),
                            ],
                          ),
                          Container(
                            height: 200,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(45)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.orange[500],
                                  Colors.yellow[100],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Expanded(
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 30, bottom: 10),
                                  child: TextFormField(
                                    key: ValueKey('username'),
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 4) {
                                        return 'Please enter at-least 4 characters';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _userName = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image.network(
                                          "https://cdn-icons-png.flaticon.com/128/1077/1077012.png",
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      labelText: 'Enter your username',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 10),
                                  child: TextFormField(
                                    key: ValueKey('email'),
                                    validator: (value) {
                                      if (value.isEmpty ||
                                          !value.contains('@')) {
                                        return 'Please enter a valid email address.';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _userEmail = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image.network(
                                          "https://cdn-icons-png.flaticon.com/128/732/732200.png",
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      labelText: 'Enter your e-mail',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 10),
                                  child: TextFormField(
                                    key: ValueKey('password'),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 7) {
                                        return 'Password must be at least 7 characters long.';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _userPassword = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image.network(
                                          "https://cdn-icons-png.flaticon.com/128/1680/1680173.png",
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      labelText: 'Enter your password',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 20),
                                  child: TextFormField(
                                    key: ValueKey('confirm password'),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 7) {
                                        return 'Password must be at least 7 characters long.';
                                      } else if (value != _userPassword) {
                                        return 'The password does not match';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _userConfirmPass = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image.network(
                                          "https://cdn-icons-png.flaticon.com/128/1057/1057667.png",
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      labelText: 'Confirm password',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 20),
                                  child: TextFormField(
                                    key: ValueKey('Restaurant address'),
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 15) {
                                        return 'Address must be at least 15 characters long.';
                                      }

                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        userAddress = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image.network(
                                          "https://cdn-icons-png.flaticon.com/128/1076/1076323.png",
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      labelText: 'Restaurant address',
                                      hintMaxLines: 3,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        _selectTime(context);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 30),
                                        // width: _width / 1.7,
                                        width: 145,
                                        height: 60,
                                        // height: _height / 9,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.yellow[500],
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: TextFormField(
                                          style: TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                          enabled: false,
                                          onChanged: (val) {
                                            setState(() {
                                              setStartTime = val;
                                            });
                                          },
                                          keyboardType: TextInputType.text,
                                          controller: _timeController,
                                          decoration: InputDecoration(
                                            disabledBorder:
                                                UnderlineInputBorder(
                                                    borderSide:
                                                        BorderSide.none),
                                            labelText: 'Opening Time',
                                            contentPadding: EdgeInsets.all(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _selectTime1(context);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 30),
                                        // width: _width / 1.7,
                                        width: 145,
                                        height: 60,
                                        // height: _height / 9,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.yellow[500],
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: TextFormField(
                                          style: TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                          enabled: false,
                                          onChanged: (val) {
                                            setState(() {
                                              setEndTime = val;
                                            });
                                          },
                                          keyboardType: TextInputType.text,
                                          controller: _timeController1,
                                          decoration: InputDecoration(
                                              disabledBorder:
                                                  UnderlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none),
                                              labelText: 'Closing Time',
                                              contentPadding:
                                                  EdgeInsets.all(10)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ButtonTheme(
                                        minWidth: 200.0,
                                        height: 50.0,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          color: Colors.yellow[700],
                                          onPressed: () {
                                            _trySubmit(
                                                _userEmail,
                                                _userPassword,
                                                setStartTime,
                                                setEndTime);
                                          },
                                          child: Text(
                                            "SignUp",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black38,
                                                fontSize: 25),
                                          ),
                                        ),
                                      ),
                                    ]),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 75, bottom: 20, top: 30),
                                  child: Row(
                                    children: <Widget>[
                                      // SizedBox(height: 20,),
                                      Text(
                                        "Already a member ? ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen()));
                                        },
                                        child: Text("Login",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.yellow[800],
                                                fontSize: 17)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}
