import 'package:flutter/material.dart';
import 'package:foor_ordering/user/restuarants.dart';
import 'signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  var isLogin = false;
  var email = '';
  var username = '';
  var password = '';
  var imageUrl = '';
  bool isoffline=false;
  var tp = '';
  bool _isLogin = false;
  var allData;
  var user_id;
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

  User firebaseUser = FirebaseAuth.instance.currentUser;
  bool isLoad = false;
  void _trySubmit(String email, String password) {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      signIn(email: email, password: password);
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;

  static Route<Object> _dialogBuilder(BuildContext context, Object arguments) {
    Widget okButton = FlatButton(
      color: Theme.of(context).accentColor,
      child: Text(
        "OK",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    return DialogRoute<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Error !',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        content: Text(
          "Account does not exist !",
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        actions: [
          okButton,
        ],
      ),
    );
  }

  Future signIn({String email, String password}) async {
    try {
      setState(() {
        isLoad = true;
      });
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      CollectionReference _collectionRef =
          FirebaseFirestore.instance.collection('user');
      QuerySnapshot querySnapshot = await _collectionRef.get();
      allData = querySnapshot.docs.map((doc) => doc.data()).toList();

      Map<String, dynamic> m = allData[0];
      print(m.keys.first);

      for (int i = 0; i < allData.length; i++) {
        if (allData[i]['email'] == email) {
          user_id = allData[i]['user_key'];
        }
      }
      print(isLogin);

      setState(() {
        isLoad = false;
        isLogin = true;
      });

      print(isLogin);

      return null;
    } on FirebaseAuthException catch (e) {
      return Navigator.of(context).restorablePush(_dialogBuilder);
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
                ): Form(
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
                                      "Login",
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
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                            obscureText: true,
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
                              print(email);
                              print(password);
                              _trySubmit(email, password);
                            },
                            child: Text(
                              "Login",
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
                                "Don't have an account ? ",
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
                                          builder: (context) => SignUp()));
                                },
                                child: Text("SignUp",
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
