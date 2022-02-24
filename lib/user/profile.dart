
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foor_ordering/intro.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
class Profile extends StatefulWidget {
  
final user_id;
int image_url;

Profile(this.user_id , this.image_url);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isoffline=false;
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
  List<String>male=[
    "asset/male-logo-1.png",
    "asset/male-logo-2.png",
    "asset/male-logo-3.png",
    "asset/male-logo-4.png",
    "asset/male-logo-5.png",
    "asset/male-logo-6.png",
    "asset/male-logo-7.png",
    "asset/male-logo-8.png",
    "asset/male-logo-9.png",
    "asset/male-logo-10.png",
    "asset/male-logo-11.png",
    "asset/male-logo-12.png",
    "asset/male-logo-13.png",
    "asset/male-logo-14.png",
    "asset/male-logo-15.png",
  ];

  List<String>female=[
    "asset/female-logo-1.png",
    "asset/female-logo-2.png",
    "asset/female-logo-3.png",
    "asset/female-logo-4.png",
    "asset/female-logo-5.png",
    "asset/female-logo-6.png",
    "asset/female-logo-7.png",
    "asset/female-logo-8.png",
    "asset/female-logo-9.png",
    "asset/female-logo-10.png",
    "asset/female-logo-11.png",
    "asset/female-logo-12.png",
    "asset/female-logo-13.png",
    "asset/female-logo-14.png",
    "asset/female-logo-15.png",
  ];

  var allData;
  var username;
  var ismale;
  var phone_number;
  var email;
  var profile_logo;
  int i=0;
  bool isMale=false;
  Future<void> getData() async {
    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection('user_details');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    Map<String, dynamic> m = allData[0];
    print(m.keys.first);

    // print(allData[0]);

    for (int i = 0; i < allData.length; i++) {
      // if (allData[i]['admin_details_items_key'] ==
      //     widget.restaurant_id.toString()) {
      //   s += i.toString();
      // }
      if(allData[i]['user_id'].toString() == widget.user_id) {
          username=allData[i]['name'];
          phone_number=allData[i]['phoneNumber'];
          email=allData[i]['email'];
        isMale = allData[i]['isMale'];

      }
    }

    setState(() {
      i = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    i==0?getData():null;
    return Scaffold(
      // backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20 , right: 20 , top: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    border: Border.all(
                      // color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  height: 300,
                  width: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 80,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:isMale? AssetImage(male[widget.image_url]):AssetImage(female[widget.image_url]),
                              fit: BoxFit.contain,
                            ),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        backgroundColor: Colors.orange[200],
                      ),
                      Text('${username}' , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold , ),),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20 , right: 20 , top: 10),
                child: Container(
                  height: 80,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    border: Border.all(
                      // color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SizedBox(width: 30,),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage("https://cdn-icons-png.flaticon.com/128/732/732200.png"),
                            fit: BoxFit.contain,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      SizedBox(width: 50,),
                      Text('${email}', style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 20 , right: 20 , top: 10),
                child: Container(
                  height: 80,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    border: Border.all(
                      // color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SizedBox(width: 30,),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage("https://cdn-icons-png.flaticon.com/512/455/455907.png"),
                            fit: BoxFit.contain,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      SizedBox(width: 50,),
                      Text('+91 ${phone_number}' , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),),
                    ],
                  ),
                ),
              ),

              Padding( padding: EdgeInsets.only(left: 20 , right: 20 , top: 10),
                child: Container(
                  height: 80,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    border: Border.all(
                      // color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: GestureDetector(
                    onTap: (){

                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Intro()));

                    },
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        SizedBox(width: 30,),
                        Container(
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

                        SizedBox(width: 50,),
                        Text("Sign Out" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),),
                      ],
                    ),
                  ),
                ),

              ),
            ],
          ),
      ),

    );
  }
}
