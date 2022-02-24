import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:email_auth/email_auth.dart';
import 'package:foor_ordering/user/restuarants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int gender = 1;
  final _formKey = GlobalKey<FormState>();
  bool isoffline=false;
  var isLogin = false;
  // bool isValid=true;
  var email;
  var username;
  var password;
  var confirmpassword;
  var phonenumber;
  bool isMale = true;
  String address;
  bool isLoad = false;
  var user_id;

  bool submitValid = false;
  EmailAuth emailAuth;
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
  void _trySubmit(String _userEmail, String _userPassword) {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      signUp(email: _userEmail, password: _userPassword);
    }
  }

  final DBRef = FirebaseDatabase.instance.reference().child('Users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;
  final databaseRef = FirebaseDatabase.instance.reference();

  Future signUp({String email, String password}) async {
    try {
      setState(() {
        isLoad = true;
      });

      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        user_id = DateTime.now().toString();
      });
      FirebaseFirestore.instance.collection('user_details').add({
        'user_id': user_id,
        'email': email,
        'isMale': isMale,
        'name': username,
        'password': password,
        'phoneNumber': phonenumber,
        'user_address': address,
      });
      FirebaseFirestore.instance.collection('user').add({
        'email': email,
        'user_key': user_id,
      });

      setState(() {
        isLoad = false;
        isLogin = true;
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoad
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            ),
          )
        : isLogin
            ? Restuarants(user_id)
            : Scaffold(
                backgroundColor: Colors.grey[200],
                body: isoffline ? Center(
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
                ):Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(150),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 350,
                                    decoration: BoxDecoration(
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
                                  Positioned(
                                    bottom: 20,
                                    right: 10,
                                    child: Text(
                                      "SignUp",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black38,
                                          fontSize: 25),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
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
                                username = value;
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
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 10),
                          child: TextFormField(
                            key: ValueKey('email'),
                            validator: (value) {
                              if (value.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                email = value;
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
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty || value.length != 10) {
                                return 'Please enter a valid Phone number';
                              }
                              return null;
                            },
                            key: ValueKey('contact number'),
                            onChanged: (value) {
                              setState(() {
                                phonenumber = value;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.network(
                                  "https://cdn-icons-png.flaticon.com/512/455/455907.png",
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Enter your contact number',
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                                password = value;
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
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 20),
                          child: TextFormField(
                            key: ValueKey('confirm password'),
                            obscureText: true,
                            validator: (value) {
                              if (value.isEmpty || value.length < 7) {
                                return 'Password must be at least 7 characters long.';
                              } else if (value != password) {
                                return 'The password does not match';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                confirmpassword = value;
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
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 20),
                          child: TextFormField(
                            key: ValueKey('User address'),
                            validator: (value) {
                              if (value.isEmpty || value.length < 10) {
                                return 'Password must be at least 10 characters long.';
                              }

                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                address = value;
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
                              labelText: 'User address',
                              hintMaxLines: 3,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    gender = 1;
                                    isMale = true;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: gender == 1
                                        ? Border.all(
                                            color: Colors.orangeAccent[200],
                                            width: 4)
                                        : Border.all(
                                            color: Colors.white, width: 0),
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
                                                "asset/male-student.png"),
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
                                    gender = 2;
                                    isMale = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: gender == 2
                                        ? Border.all(
                                            color: Colors.orangeAccent[200],
                                            width: 4)
                                        : Border.all(
                                            color: Colors.white, width: 0),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          // border: Border.all(color: Colors.yellow[300]),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              "https://cdn-icons-png.flaticon.com/128/6754/6754947.png",
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
                          height: 40,
                        ),
                        ButtonTheme(
                          minWidth: 200.0,
                          height: 50.0,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.yellow[700],
                            onPressed: () {
                              _trySubmit(email, password);
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
                        SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 75, bottom: 20, top: 10),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Already a member ? ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
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
              );
  }
}
