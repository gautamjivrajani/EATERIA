import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foor_ordering/admin/admin_signup.dart';
import 'package:foor_ordering/user/signup.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class Intro extends StatefulWidget {

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  // StreamSubscription connection;
  //
  bool isoffline = false;
  //
  // @override
  // void initState() {
  //   connection = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
  //     // whenevery connection status is changed.
  //     if(result == ConnectivityResult.none){
  //       //there is no any connection
  //       setState(() {
  //         isoffline = true;
  //       });
  //     }else if(result == ConnectivityResult.mobile){
  //       //connection is mobile data network
  //       setState(() {
  //         isoffline = false;
  //       });
  //     }else if(result == ConnectivityResult.wifi){
  //       //connection is from wifi
  //       setState(() {
  //         isoffline = false;
  //       });
  //     }else if(result == ConnectivityResult.ethernet) {
  //       //connection is from wired connection
  //       setState(() {
  //         isoffline = false;
  //       });
  //     }
  //     // }else if(result == ConnectivityResult.bluetooth){
  //     //   //connection is from bluetooth threatening
  //     //   setState(() {
  //     //     isoffline = false;
  //     //   });
  //     // }
  //   });
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   connection.cancel();
  //   super.dispose();
  // }
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
      ):Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: Container(
                  child: Center(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText('USER'),
                          // WavyAnimatedText('Look at the waves'),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {
                          print("Tap Event");
                        },
                      ),
                    ),
                  ),
                  height: MediaQuery.of(context).size.width / 1.2,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(95)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.yellow[100], Colors.orange[500]],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
                child: Container(
                  child: Center(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText('ADMIN'),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {
                          print("Tap Event");
                        },
                      ),
                    ),
                  ),
                  height: MediaQuery.of(context).size.width / 1.2,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(95)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.yellow[100], Colors.orange[500]],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
