import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin/admin_first_screen.dart';
import 'cart.dart';
import 'intro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'user/restuarants.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:custom_splash/custom_splash.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


import 'dart:async';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  runApp((MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  Widget GK() {
    return CustomSplash(
      imagePath: 'asset/logo.png',
      backGroundColor: Colors.white,
      // backGroundColor: Color(0xfffc6042),
      animationEffect: 'zoom-in',
      logoSize: 800,
      home: (user == null
          ? Intro()
          : (admin ? AdminFirstScreen(key) : Restuarants(key))),
      // customFunction: await getData(),
      duration: 2500,
      type: CustomSplashType.StaticDuration,

      // outputAndHome: op,
    );
  }

  var user = FirebaseAuth.instance.currentUser;

  var allData;

  var key;

  var allData1;
  int i = 0;
  bool admin = false;
  bool isLoad = false;
  Future<void> getData() async {
    print(FirebaseAuth.instance.currentUser.email);
    setState(() {
      isLoad = true;
    });
    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection('user');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    CollectionReference _collectionRef1 =
    FirebaseFirestore.instance.collection('admin');
    QuerySnapshot querySnapshot1 = await _collectionRef1.get();
    allData1 = querySnapshot1.docs.map((doc) => doc.data()).toList();
    for (int i = 0; i < allData.length; i++) {
      if (allData[i]['email'] == user.email) {
        setState(() {
          key = allData[i]['user_key'];
          admin = false;
        });
      }
    }
    for (int i = 0; i < allData1.length; i++) {
      if (allData1[i]['email'] == user.email) {
        setState(() {
          key = allData1[i]['admin_key'];
          admin = true;
        });
      }
    }
    print(admin);
    setState(() {
      isLoad = false;
      i = 1;
    });
  }

  bool checkInternet = false;
  Future<void> check() async {
    // checkInternet = await InternetConnectionChecker().hasConnection;
  }

  @override
  Widget build(BuildContext context) {
    check();
    i == 0 ? getData() : null;
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (ctx) => Cart())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EATERIA',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        // home: checkInternet ? GK() : Scaffold(body: Center(child: CircularProgressIndicator(),),),
        home: isoffline ? Scaffold(
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
        ):GK(),
      ),
    );
  }
}
