import 'package:flutter/material.dart';
import 'package:foor_ordering/user/food_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
class Home extends StatefulWidget {
  @override
  var restaurant_id;
  final user_id;

  Home(this.restaurant_id, this.user_id);
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isoffline=false; final Connectivity _connectivity = Connectivity();
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
  int rating(double ans1, double rat1) {
    double ans;
    int rat;
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
    return rat;
  }

  String s = "";
  String search_item;
  int likes = 15;
  int amount = 350;
  bool liked = false;
  int container_index = 1;
  int string_index = 10;
  int currentPage = 0;
  var allData;
  var allData1;
  int i = 0;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 10),
          child: TextFormField(
            key: ValueKey('searched item'),
            onChanged: (value) {
              setState(() {
                search_item = value;
                if (search_item.isNotEmpty && search_item != null)
                  container_index = 6;
                else
                  container_index = 1;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/128/49/49116.png",
                  width: 15,
                  height: 15,
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
        Container(
          margin: EdgeInsets.symmetric(vertical: 20.0),
          height: 50.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 1;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: container_index == 1
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/2082/2082045.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "All Items",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 2;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: container_index == 2
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/128/3823/3823394.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Starters",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 3;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: container_index == 3
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/128/1037/1037762.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Fast Food",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 4;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 135.0,
                    decoration: BoxDecoration(
                      color: container_index == 4
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/926/926292.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "MainCourse",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      container_index = 5;
                    });
                  },
                  child: Container(
                    height: 60.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color: container_index == 5
                          ? Colors.yellow[100]
                          : Colors.white,
                      border: Border.all(
                        // color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/3157/3157358.png"),
                                fit: BoxFit.contain),
                            shape: BoxShape.rectangle,
                            // border:
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Desert",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: StreamBuilder<QuerySnapshot>(

                stream: ((search_item == null || search_item.length == 0) &&
                        container_index == 1)
                    ? FirebaseFirestore.instance
                        .collection("admin_details_items")
                        .where('admin_details_items_key',
                            isEqualTo: widget.restaurant_id.toString())
                        .snapshots()
                    : (container_index == 2
                        ? FirebaseFirestore.instance
                            .collection("admin_details_items")
                            .where('admin_details_items_key',
                                isEqualTo: widget.restaurant_id.toString())
                            .where('type', isEqualTo: 'Starter')
                            .snapshots()
                        : (container_index == 3
                            ? FirebaseFirestore.instance
                                .collection("admin_details_items")
                                .where('admin_details_items_key',
                                    isEqualTo: widget.restaurant_id.toString())
                                .where('type', isEqualTo: 'Fast Food')
                                .snapshots()
                            : (container_index == 4
                                ? FirebaseFirestore.instance
                                    .collection("admin_details_items")
                                    .where('admin_details_items_key',
                                        isEqualTo:
                                            widget.restaurant_id.toString())
                                    .where('type', isEqualTo: 'Main Course')
                                    .snapshots()
                                : (container_index == 5
                                    ? FirebaseFirestore.instance
                                        .collection("admin_details_items")
                                        .where('admin_details_items_key',
                                            isEqualTo:
                                                widget.restaurant_id.toString())
                                        .where('type', isEqualTo: 'Desert')
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection("admin_details_items")
                                        .where('admin_details_items_key',
                                            isEqualTo:
                                                widget.restaurant_id.toString())
                                        .where('name',
                                            isGreaterThanOrEqualTo: search_item)
                                        .where('name',
                                            isLessThan: search_item + 'z')
                                        .snapshots())))),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return GridView.builder(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodCard(
                                    false,
                                    3,
                                    snapshot.data.docs[index]['name'],
                                    snapshot.data.docs[index]['price'],
                                    snapshot.data.docs[index]['image'],
                                    snapshot.data.docs[index]
                                        ['admin_details_items_key'],
                                    snapshot.data.docs[index]['item_id']
                                        .toString(),
                                    widget.user_id),
                              ),
                            );
                          },
                          child: Container(
                            height: 400,
                            width: 400,
                            child: Card(
                              elevation: 12,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        snapshot.data.docs[index]['veg'] ==
                                                "veg"
                                            ? Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      "https://t3.ftcdn.net/jpg/03/37/98/48/240_F_337984829_QKSzohwBmipYPA0EQSKotZ7z4hhoig3z.jpg",
                                                    ),
                                                    fit: BoxFit.contain,
                                                  ),
                                                  shape: BoxShape.rectangle,
                                                ),
                                              )
                                            : Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      "https://t4.ftcdn.net/jpg/03/37/98/31/240_F_337983112_0Uv0KJHNWrQy4q4a8SITdOIhsjeqqQoh.jpg",
                                                    ),
                                                    fit: BoxFit.contain,
                                                  ),
                                                  shape: BoxShape.rectangle,
                                                ),
                                              ),


                                      ],
                                    ),
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.green[500],
                                    radius: 50,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(snapshot
                                          .data
                                          .docs[index]['image']), //NetworkImage
                                      radius: 50,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data.docs[index]['name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[

                                      Text(
                                        '${rating(snapshot.data.docs[index]['ratings'].toDouble(), snapshot.data.docs[index]['user_count'].toDouble())}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Container(
                                        height: 20,
                                        width: 20,
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
                                  ),
                                  Text(
                                      '\u{20B9}${snapshot.data.docs[index]['price']}' ,
                                  style: TextStyle(fontWeight: FontWeight.bold , fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2 / 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: snapshot.data.docs.length,
                    );
                  }
                })),
      ],
    );
  }
}
