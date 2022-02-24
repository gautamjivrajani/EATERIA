
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'menu_card.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
class Restuarants extends StatefulWidget {
  final user_id;
  Restuarants(this.user_id);
  @override
  _RestuarantsState createState() => _RestuarantsState();
}

class _RestuarantsState extends State<Restuarants> {
  var allData;
  bool isoffline=false;

  int i = 0;
  String search_item = '';
  // @override
  // void initState() {
  //   // TODO: implement initState
  //
  //   getData();
  //   super.initState();
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
  Future<void> getData() async {
    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection('admin_details');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    // print(allData);
    // print(allData[0]);

    for (int i = 0; i < allData.length; i++) {
      Map<dynamic, dynamic> m = allData[i];
      print("admin_details_items........admin");
      print(allData[i]['admin_details_key']);
      // print(m.keys);
    }

    setState(() {
      i = 1;
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
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Text("Restaurants"),
      ),
      body: Column(children: [

        Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 10),
          child: TextFormField(
            key: ValueKey('searched item'),
            onChanged: (value) {
              setState(() {
                search_item = value;
              });
            },
            decoration: InputDecoration(

              prefixIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/128/49/49116.png",
                  width: 20,
                  height: 20,
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
        StreamBuilder(
            stream: (search_item != null && search_item.length != 0)
                ? FirebaseFirestore.instance
                .collection("admin_details")
                .where('name', isGreaterThanOrEqualTo: search_item)
                .where('name', isLessThan: search_item + 'z')
                .snapshots()
                : FirebaseFirestore.instance
                .collection("admin_details")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,



                                MaterialPageRoute(
                                    builder: (context) => MenuCard(snapshot.data
                                        .docs[index]['admin_details_key'],widget.user_id)));
                          },
                          child: Stack(children: [
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Container(
                                height: 350,
                                width: 350,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      // "https://tse4.mm.bing.net/th?id=OIP.6rca-kJFjLs2L1rQ_fsOUAHaF6&pid=Api&P=0&w=212&h=169",
                                      snapshot.data.docs[index]['image'],
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 250, left: 30, right: 30),
                              child: Opacity(
                                opacity: 0.6,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,

                                  child: Column(
                                    children: [
                                      Text(
                                        snapshot.data
                                            .docs[index]['name'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          // SizedBox(width: 10,),
                                          Container(
                                            height: 25,
                                            width: 25,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image:
                                                AssetImage("asset/address_logo.png"),
                                                fit: BoxFit.contain,
                                              ),
                                              shape: BoxShape.rectangle,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            snapshot.data
                                                .docs[index]['userAddress'],
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [

                                            Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "asset/open.png"),
                                                  fit: BoxFit.contain,
                                                ),
                                                shape: BoxShape.rectangle,
                                              ),
                                            ),
                                            Text(
                                              snapshot.data
                                                  .docs[index]['start'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "asset/closed.png"),
                                                  fit: BoxFit.contain,
                                                ),
                                                shape: BoxShape.rectangle,
                                              ),
                                            ),
                                            Text(
                                              snapshot.data
                                                  .docs[index]['end'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  height: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            )
                          ])

                      );
                    },
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.docs.length,
                  ),
                );
              }
            }),
      ]),
    );
  }
}
