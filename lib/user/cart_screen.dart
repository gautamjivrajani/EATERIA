import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foor_ordering/user/menu_card.dart';
import '../cart.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class CartScreen extends StatefulWidget {
  final restaurant_id;
  final user_id;
  final name;
  final image;
  final address;
  final phone;


  CartScreen(this.restaurant_id, this.user_id, this.name, this.image,
      this.address, this.phone);
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<String> foodItem = [];
  List<double> perItemPrice = [];
  bool isoffline=false;
  List<int> count = [];
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
  double grandTotal = 0;
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    for (int i = 0; i < cartData.l.length; i++) {
      grandTotal += cartData.l[i].count * cartData.l[i].per_item_price;
    }
    print(widget.restaurant_id);
    print(widget.image);
    print(widget.user_id);
    return SafeArea(
      child: isoffline ? Scaffold(
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
        // backgroundColor: Colors.blueGrey[900],
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MenuCard(widget.restaurant_id, widget.user_id)),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  iconSize: 30,
                ),
                Text(
                  'Cart',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                  ),
                  iconSize: 30,
                ),
              ],
            ),
            Expanded(
              child: cartData.l.length == 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 225, left: 30),
                      child: Container(
                        height: 120,
                        width: 250,
                        child: Text(
                          "No items in the cart yet !",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartData.l.length,
                      itemBuilder: (context, index) {
                        return cartData.l.length == 0
                            ? Center(child: CircularProgressIndicator())
                            : Card(
                                // color: Colors.yellow[200],
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.white70, width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            cartData.delete(index);
                                          },
                                          icon: Icon(Icons.clear),
                                          iconSize: 15,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 30, left: 15, right: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CircleAvatar(
                                            radius: 40,
                                            backgroundImage: NetworkImage(
                                                cartData.l[index].img_url),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${cartData.l[index].food_name}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    height: 15,
                                                    width: 15,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            'https://cdn-icons-png.flaticon.com/512/1490/1490817.png'),
                                                        fit: BoxFit.contain,
                                                      ),
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    '${cartData.l[index].per_item_price}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 80,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Total :-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                    height: 15,
                                                    width: 15,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            'https://cdn-icons-png.flaticon.com/512/1490/1490817.png'),
                                                        fit: BoxFit.contain,
                                                      ),
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    '${cartData.l[index].per_item_price * cartData.l[index].count}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (cartData
                                                              .l[index].count <=
                                                          1) {
                                                      } else {
                                                        setState(() {
                                                          cartData.l[index]
                                                              .count -= 1;
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 30,
                                                      width: 30,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            "https://cdn-icons-png.flaticon.com/128/1828/1828899.png",
                                                          ),
                                                          fit: BoxFit.contain,
                                                        ),
                                                        shape:
                                                            BoxShape.rectangle,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      '${cartData.l[index].count}'),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        cartData.l[index]
                                                            .count += 1;
                                                        print(cartData
                                                            .l[index].count);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 30,
                                                      width: 30,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            "https://cdn-icons-png.flaticon.com/128/1828/1828919.png",
                                                          ),
                                                          fit: BoxFit.contain,
                                                        ),
                                                        shape:
                                                            BoxShape.rectangle,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${cartData.GrandTotal()}',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: GestureDetector(
                            onTap: () {
                              if (cartData.len() == 0) {
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
                                              "No items in the Cart !",
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
                                            widget.restaurant_id,
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
                                          width: 18,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Success !",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "The order is placed successfully ! ",
                                              style: TextStyle(
                                                  fontSize: 11,
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

                                for (int i = 0; i < cartData.l.length; i++) {
                                  foodItem.add(cartData.l[i].food_name);
                                  perItemPrice
                                      .add(cartData.l[i].per_item_price);
                                  count.add(cartData.l[i].count);
                                }
                                FirebaseFirestore.instance
                                    .collection('user_requests')
                                    .add({
                                  'end_time':
                                      DateTime.now().add(Duration(seconds: 30)),
                                  'request_id': DateTime.now().toString(),
                                  'restaurant_id': widget.restaurant_id,
                                  'user_id': widget.user_id,
                                  'status': 1,
                                  'total': cartData.GrandTotal(),
                                  'food_name_list': foodItem,
                                  'per_item_price_list': perItemPrice,
                                  'count_list': count,
                                  'image': widget.image,
                                  'name': widget.name,
                                  'phone': widget.phone,
                                  'address': widget.address
                                });
                                cartData.deleteAll();
                              }
                            },
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                    "Place Order",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[900],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              height: 167,
              decoration: BoxDecoration(
                color: Colors.orange[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
