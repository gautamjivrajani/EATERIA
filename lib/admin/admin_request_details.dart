import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter_sms/flutter_sms.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class AdminRequestDetails extends StatefulWidget {
  final adminId;
  final request_id;
  AdminRequestDetails(this.adminId, this.request_id);
  @override
  _AdminRequestDetailsState createState() => _AdminRequestDetailsState();
}

class _AdminRequestDetailsState extends State<AdminRequestDetails> {
  int index = 1;
  bool submitted = false;
  bool isoffline=false;
  String accepted =
      "ACCEPTED ! \n Your order is accepted successfully and you will receive a call from our end soon \n Thanks !";
  String rejected = "REJECTED ! \n Your order is rejected .";

  /*
  * 0 accept
  * 1 reject
  * */
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
  String _message;
  Future<void> _sendSMS(List<String> recipients, String m) async {
    try {
      String _result = await sendSMS(message: m, recipients: recipients);
      setState(() => _message = _result);
    } catch (error) {
      setState(() => _message = error.toString());
    }
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
      // backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Text("Request from USERID"),
        backgroundColor: Colors.yellow[100],
        // elevation: 100.0,
        // shadowColor: Colors.yellow,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
        // automaticallyImplyLeading: true,
        bottomOpacity: 20,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('user_requests')
                .where('request_id', isEqualTo: widget.request_id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.data.docs[0]['end_time']
                        .toDate()
                        .isBefore(DateTime.now()) &&
                    snapshot.data.docs[0]['status'] == 1) {
                  FirebaseFirestore.instance
                      .collection('user_requests')
                      .where('request_id',
                          isEqualTo: snapshot.data.docs[0]['request_id'])
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((documentSnapshot) {
                      documentSnapshot.reference.update({
                        'status': 4,
                      });
                    });
                  });
                }
                return Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          image: DecorationImage(
                              image:
                                  NetworkImage(snapshot.data.docs[0]['image']),
                              fit: BoxFit.contain),
                          border: Border.all(
                            // color: Colors.red,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      snapshot.data.docs[0]['name'],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: max(4.0 * 10 + 50, 200),
                      width: 350,
                      child: ListView.builder(
                        itemBuilder: (context, idx) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    // '${snapshot.data.docs[index]['food_name_list'][idx]}',
                                    snapshot.data.docs[0]['food_name_list']
                                        [idx],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '${snapshot.data.docs[0]['count_list'][idx]} X',
                                        // "tp2",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                "asset/rupee-symbol.png"),
                                            fit: BoxFit.contain,
                                          ),
                                          shape: BoxShape.rectangle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        // "tp3",
                                        '${snapshot.data.docs[0]['per_item_price_list'][idx]}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                        itemCount: snapshot.data.docs[0]['count_list'].length,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        "Grand total :- value",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    (snapshot.data.docs[0]['status'] == 2 ||
                            snapshot.data.docs[0]['status'] == 3)
                        ? Text(
                            "The response for this request is already submitted !",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          )
                        : snapshot.data.docs[0]['status'] == 4
                            ? Text(
                                "The request by this user has Expired !",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        index = 0;
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 140,
                                      // color: Colors.green,
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? Colors.green
                                            : Colors.white,
                                        border: Border.all(
                                          color: index == 0
                                              ? Colors.yellow[100]
                                              : Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      child: Center(
                                          child: Text(
                                        "Accept",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: index == 0
                                                ? Colors.white
                                                : Colors.black),
                                      )),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        index = 1;
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 140,
                                      // color: Colors.green,
                                      decoration: BoxDecoration(
                                        color: index == 1
                                            ? Colors.red
                                            : Colors.white,
                                        border: Border.all(
                                          color: index == 1
                                              ? Colors.yellow[100]
                                              : Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      child: Center(
                                          child: Text(
                                        "Reject",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: index == 1
                                                ? Colors.white
                                                : Colors.black),
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          (index == 0 && submitted == false)
                              ? FirebaseFirestore.instance
                                  .collection('user_requests')
                                  .where('request_id',
                                      isEqualTo: snapshot.data.docs[0]
                                          ['request_id'])
                                  .get()
                                  .then((querySnapshot) {
                                  querySnapshot.docs
                                      .forEach((documentSnapshot) {
                                    documentSnapshot.reference.update({
                                      'status': 2,
                                    });
                                  });
                                })
                              : FirebaseFirestore.instance
                                  .collection('user_requests')
                                  .where('request_id',
                                      isEqualTo: snapshot.data.docs[0]
                                          ['request_id'])
                                  .get()
                                  .then((querySnapshot) {
                                  querySnapshot.docs
                                      .forEach((documentSnapshot) {
                                    documentSnapshot.reference.update({
                                      'status': 3,
                                    });
                                  });
                                });
                          // _sendSMS(message, recipents);
                          // sendSms();

                          index == 0
                              ? _sendSMS(['${snapshot.data.docs[0]['phone']}'],
                                  '${accepted}')
                              : _sendSMS(['${snapshot.data.docs[0]['phone']}'],
                                  '${rejected}');

                          final snackBar = snapshot.data.docs[0]['status'] == 0
                              ? SnackBar(
                                  elevation: 10,
                                  duration: Duration(seconds: 5),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                  // shape: ShapeBorder.,
                                  backgroundColor:
                                      Colors.green[300].withOpacity(0.7),
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
                                              image: AssetImage(
                                                  "asset/right-symbol.png"),
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
                                              "SUCCESSFUL!",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "The order has been accepted !",
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
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                    },
                                  ),
                                )
                              : SnackBar(
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
                                              "The response is already given !",
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

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
      ),
    );
  }
}
