import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
class UserRequestHistory extends StatefulWidget {
  @override
  _UserRequestHistoryState createState() => _UserRequestHistoryState();
}

class _UserRequestHistoryState extends State<UserRequestHistory> {
  int status = 1;
  bool expanded = false;
  var allData;
  bool loading = false;
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
  /*
  0 pending
  1 rejected
  2 accepted
  3 timed out
   */

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

      body: SafeArea(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("user_requests")
                .snapshots(),
            builder: (context, snapshot) {

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
                          if (snapshot.data.docs[index]['end_time']
                              .toDate()
                              .isBefore(DateTime.now()) &&  snapshot.data.docs[index]['status']==1 ) {

                            FirebaseFirestore.instance
                                .collection('user_requests')
                                .where('request_id',
                                isEqualTo: snapshot.data.docs[index]
                                ['request_id'])
                                .get()
                                .then((querySnapshot) {
                              querySnapshot.docs.forEach((documentSnapshot) {
                                documentSnapshot.reference.update({
                                  'status': 4,
                                });
                              });
                            });

                          }

                          return !snapshot.hasData
                              ? Center(
                                  child: Container(
                                  height: 100,
                                  width: 100,
                                  child: Text("No Requests yet !"),
                                ))
                              : Padding(
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
                                                snapshot.data.docs[index]['status'] == 1
                                                    ? Text(
                                                        "Pending",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.orange),
                                                      )
                                                    : (snapshot.data.docs[index]['status']  == 2
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
                                                        : (snapshot.data.docs[index]['status']  == 3
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
                                                    expanded = !expanded;
                                                  });
                                                },
                                                icon: Icon(expanded
                                                    ? Icons.expand_less
                                                    : Icons.expand_more))
                                          ],
                                        ),

                                        expanded
                                            ? Expanded(
                                              child: Container(
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
                                                ),
                                            )
                                            : SizedBox(
                                                height: 0,
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                        },
                        itemCount: snapshot.data.docs.length,
                      );
              }
            }),
      ),
    );
  }
}
