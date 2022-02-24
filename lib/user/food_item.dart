import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class FoodItem extends StatefulWidget {
  @override
  _FoodItemState createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> {
  int likes = 15;
  int amount = 350;
  bool liked = false;
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
        child: Container(
          height: 400,
          width: 400,
          child: Card(
            elevation: 12,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    liked
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                liked = !liked;
                              });
                            },
                            icon: Icon(Icons.favorite_outline))
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                liked = !liked;
                              });
                            },
                            icon: Icon(Icons.favorite),
                          ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: Colors.green[500],
                  radius: 108,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://tse1.mm.bing.net/th?id=OIP.tUMabKFxV5svI9msbj_ozwHaEK&pid=Api&P=0&w=272&h=153"), //NetworkImage
                    radius: 108,
                  ),
                ),

                Text(
                  "Black Pepper Crab",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Non-Veg"),
                    SizedBox(
                      width: 40,
                    ),
                    Icon(Icons.favorite_outline),
                    Text("${likes} likes"),
                  ],
                ),
                Text('\u{20B9}${amount}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class FoodItemDetails {
  String image_url;
  String food_name;
  int likes;
  double price;
  bool veg;
  bool liked;

  FoodItemDetails(String image_url, String food_name, int likes, double price,
      bool veg, bool liked) {
    this.image_url = image_url;
    this.food_name = food_name;
    this.likes = likes;
    this.price = price;
    this.veg = veg;
    this.liked = liked;
  }
}
