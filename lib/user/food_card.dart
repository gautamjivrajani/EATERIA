import 'package:flutter/material.dart';
import '../cart.dart';
import 'menu_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class FoodCard extends StatefulWidget {
  bool liked;
  int ratings;
  String food_name;
  int count = 1;
  double price;
  String image_url;
  String restaurent_id;
  String item_id;
  final user_id;
  bool isoffline=false;
  FoodCard(this.liked, this.ratings, this.food_name, this.price, this.image_url,
      this.restaurent_id, this.item_id, this.user_id);

  @override
  _FoodCardState createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  int i = 0;
  double ans;
  var allData1;
  int up;
  int down;
  int rat = 0;
  var docId;
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
  Widget dialogBox(BuildContext context) {
    double givenRatings = 0;
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("admin_details_items")
              .where('item_id', isEqualTo: widget.item_id.toString())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    border: Border.all(
                        // color: Colors.red,
                        width: 1,
                        color: Colors.black),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  height: 200,
                  width: 320,
                  child: Column(children: <Widget>[
                    // Text("tp"),
                    // Text("Rate" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 40 , color: Colors.black),),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("asset/rate-now-logo.png"),
                          fit: BoxFit.contain,
                        ),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RatingBar.builder(
                        initialRating: 2,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                        onRatingUpdate: (rating) {
                          givenRatings = rating;
                        }),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('admin_details_items')
                                  .where('item_id', isEqualTo: widget.item_id)
                                  .get()
                                  .then((querySnapshot) {
                                querySnapshot.docs.forEach((documentSnapshot) {
                                  documentSnapshot.reference.update({
                                    'ratings': snapshot.data.docs[0]
                                            ['ratings'] +
                                        givenRatings,
                                    'user_count':
                                        snapshot.data.docs[0]['user_count'] + 1,
                                  });
                                });
                              });
                              Navigator.pop(context);
                              final snackBar = SnackBar(
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
                                            "Ratings Updated !",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            "The ratings for this food item has\n been updated successfully !",
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
                            },
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )),
                      ],
                    ),
                  ]));
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // i == 0 ? getData() : null;
    final cartData = Provider.of<Cart>(context);
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
      backgroundColor: Colors.orange[400],
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Container(
                  // color: Colors.orange[400],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Padding(padding: EdgeInsets.only(top: 120)),
                      Padding(
                        padding: EdgeInsets.only(top: 50, left: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuCard(
                                        widget.restaurent_id, widget.user_id)));
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("asset/previous.png"),
                                fit: BoxFit.contain,
                              ),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(35),
                    topLeft: Radius.circular(35),
                    // bottomLeft: Radius.circular(15),
                    // bottomRight: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 170,
                      ),
                      Text(
                        widget.food_name,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                          ),
                          Container(
                            height: 20,
                            width: 150,
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("admin_details_items")
                                    .where('item_id',
                                        isEqualTo: widget.item_id.toString())
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    return Rating(
                                        snapshot.data.docs[0]['ratings']
                                            .toDouble(),
                                        snapshot.data.docs[0]['user_count']
                                            .toDouble());
                                  }
                                }),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              dialogBox(context);
                            },
                            child: Text(
                              "Rate now ?",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15,
                          ),
                          // Text("price per item"),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("asset/rupee-symbol.png"),
                                fit: BoxFit.contain,
                              ),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${widget.price * widget.count}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.black),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          // Text("minus"),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (widget.count <= 1) {
                                } else {
                                  widget.count--;
                                }
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("asset/minus-button.png"),
                                  fit: BoxFit.contain,
                                ),
                                shape: BoxShape.rectangle,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          // Text("count"),
                          Container(
                            height: 45,
                            width: 45,
                            child: CircleAvatar(
                              backgroundColor: Colors.yellow[700],
                              child: Text(
                                '${widget.count}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          // Text("plus"),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.count++;
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("asset/plus-button.png"),
                                  fit: BoxFit.contain,
                                ),
                                shape: BoxShape.rectangle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        height: 50,
                        width: 250,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.orange[400],
                          onPressed: () {
                            // print(cartData.l[0].food_name);
                            // print(cartData.l.length);
                            if (cartData.l.length != 0) {
                              if ((cartData.l[0].restaurant_id !=
                                  widget.restaurent_id)) {
                                final snackBar = SnackBar(
                                  elevation: 10,
                                  duration: Duration(seconds: 5),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                  // shape: ShapeBorder.,
                                  backgroundColor:
                                      Colors.red[300].withOpacity(0.7),
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
                                              image: AssetImage(
                                                  "asset/wrong-logo.png"),
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
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              "OOPS !",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "The food item should be \nfrom the same Restaurant",
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
                              } else {
                                int f = 0;
                                for (int i = 0; i < cartData.l.length; i++) {
                                  if (cartData.l[i].item_id == widget.item_id) {
                                    f++;
                                    break;
                                  }
                                }
                                if (f == 0) {
                                  cartData.addItem(
                                      '${widget.image_url}',
                                      widget.count,
                                      widget.price,
                                      widget.food_name,
                                      widget.restaurent_id,
                                      widget.item_id);

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MenuCard(
                                              widget.restaurent_id,
                                              widget.user_id)));

                                  final snackBar = SnackBar(
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
                                                "Ratings Updated !",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "The ratings for this food item has\n been updated successfully !",
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
                                } else {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MenuCard(
                                              widget.restaurent_id,
                                              widget.user_id)));
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
                              }
                            } else {
                              cartData.addItem(
                                  '${widget.image_url}',
                                  widget.count,
                                  widget.price,
                                  widget.food_name,
                                  widget.restaurent_id,
                                  widget.item_id);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MenuCard(
                                          widget.restaurent_id,
                                          widget.user_id)));
                              final snackBar = SnackBar(
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
                                            "SUCCESS !",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            "The ratings for this food item has\n been updated successfully !",
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
                            // cart.any((item) => item.contains('${widget.item_id}'));

                            // _trySubmit(email, password);
                          },
                          child: Text(
                            "Add to Cart",
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
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 250),
            child: new Center(
              child: new Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.image_url,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                height: 250.0,
                width: 250.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget Rating(double ans1, double rat1) {
  print(rat1);
  double ans;
  double rat;
  if (ans1 == 0 || rat1 == 0) {
    ans = 0;
  } else {
    ans = ans1 / rat1;
  }
  if (ans >= 0 && ans < 0.5) {
    rat = 0;
  } else if (ans >= 0.5 && ans < 1) {
    rat = 1;
  } else if (ans >= 1 && ans < 1.5) {
    rat = 1;
  } else if (ans >= 1.5 && ans < 2) {
    rat = 2;
  } else if (ans >= 2.0 && ans < 2.5) {
    rat = 2;
  } else if (ans >= 2.5 && ans < 3) {
    rat = 3;
  } else if (ans >= 3.0 && ans < 3.5) {
    rat = 3;
  } else if (ans >= 3.5 && ans < 4) {
    rat = 4;
  } else if (ans >= 4 && ans < 4.5) {
    rat = 4;
  } else if (ans >= 4.5 && ans <= 5) {
    rat = 5;
  }

  double i = rat;

  if (i == 5) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
      ],
    );
  } else if (i == 4) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
      ],
    );
  } else if (i == 3) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
      ],
    );
  } else if (i == 2) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
      ],
    );
  } else if (i == 1) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/star_logo.png"),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
      ],
    );
  } else {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://cdn-icons-png.flaticon.com/128/1040/1040230.png",
              ),
              fit: BoxFit.contain,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
      ],
    );
  }
}
