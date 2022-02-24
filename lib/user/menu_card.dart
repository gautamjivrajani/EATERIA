
import 'package:flutter/material.dart';
import 'package:foor_ordering/user/cart_screen.dart';
import 'package:foor_ordering/user/home.dart';
import 'package:foor_ordering/user/profile.dart';
import 'package:foor_ordering/user/user_request_history.dart';
import 'dart:math';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';




class MenuCard extends StatefulWidget {
  @override
  var restaurant_id;
  final user_id;

  MenuCard(this.restaurant_id, this.user_id);

  _MenuCardState createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool isoffline=false;
  String s = "";
  String search_item;
  int likes = 15;
  int amount = 350;
  bool liked = false;
  int container_index = 1;
  int string_index = 10;
  int image_url;
  int currentPage = 0;

  bool isMale=false;
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


  void randomNumber() {
    var random = new Random();

    int min = 0;

    int max = 14;

    int result = min + random.nextInt(max - min);
    image_url = result;

    setState(() {
      ran=1;
    });
    print(result);
  }

  List<String>male=[
    "asset/male-logo-1.png",
    "asset/male-logo-2.png",
    "asset/male-logo-3.png",
    "asset/male-logo-4.png",
    "asset/male-logo-5.png",
    "asset/male-logo-6.png",
    "asset/male-logo-7.png",
    "asset/male-logo-8.png",
    "asset/male-logo-9.png",
    "asset/male-logo-10.png",
    "asset/male-logo-11.png",
    "asset/male-logo-12.png",
    "asset/male-logo-13.png",
    "asset/male-logo-14.png",
    "asset/male-logo-15.png",
  ];

  List<String>female=[
    "asset/female-logo-1.png",
    "asset/female-logo-2.png",
    "asset/female-logo-3.png",
    "asset/female-logo-4.png",
    "asset/female-logo-5.png",
    "asset/female-logo-6.png",
    "asset/female-logo-7.png",
    "asset/female-logo-8.png",
    "asset/female-logo-9.png",
    "asset/female-logo-10.png",
    "asset/female-logo-11.png",
    "asset/female-logo-12.png",
    "asset/female-logo-13.png",
    "asset/female-logo-14.png",
    "asset/female-logo-15.png",
  ];

  var allData1;
  int i = 0;
  int index = 0;
  int ran=0;

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();

  Future<void> fetchData() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('user_details');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    allData1 = querySnapshot.docs.map((doc) => doc.data()).toList();
  }
var name;
  var image;

  var username;
  var ismale;
  var address;
  var phone_number;
  var email;
  var profile_logo;
  var allData;
  Future<void> getData() async {
    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection('user_details');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    CollectionReference _collectionRef1 =
    FirebaseFirestore.instance.collection('admin_details');
    QuerySnapshot querySnapshot1 = await _collectionRef1.get();
    allData1 = querySnapshot1.docs.map((doc) => doc.data()).toList();

    for (int i = 0; i < allData1.length; i++) {

      if(allData1[i]['admin_details_key'] == widget.restaurant_id) {
        setState(() {
          name=allData1[i]['name'];
          image=allData1[i]['image'];
          print(name);
          print(image);
        });

      }
    }
    for (int i = 0; i < allData.length; i++) {

      if(allData[i]['user_id'].toString() == widget.user_id) {
        setState(() {
          username=allData[i]['name'];
          phone_number=allData[i]['phoneNumber'];
          address=allData[i]['user_address'];
         isMale=allData[i]['isMale'];
        });

      }
    }

    setState(() {
      i = 1;
    });
  }


  @override


  Widget build(BuildContext context) {
    i==0?getData():null;

    ran==0 ? randomNumber(): null;

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
    ):SideMenu(
      background: Colors.orange[200],
      key: _sideMenuKey,
      menu: SingleChildScrollView(

        // padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(

              padding:  EdgeInsets.only(left: 16.0),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:isMale? AssetImage(male[image_url]):AssetImage(female[image_url]),
                          fit: BoxFit.contain,
                        ),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    radius: 60.0,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '${username}',
                    style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold , fontSize: 20),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
            SizedBox(height: 15,),
            ListTile(
              onTap: () {
                final _state = _sideMenuKey.currentState;
                if (_state.isOpened)
                  _state.closeSideMenu(); // close side menu
                else
                  _state.openSideMenu();
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ));
                setState(() {
                  index=1;
                });

              },
              leading: const Icon(Icons.home, size: 40.0, color: Colors.black),
              title: const Text("Home" , style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold , fontSize: 20)),
              // textColor: Colors.white,
              dense: true,
            ),
            SizedBox(height: 15,),
            ListTile(
              onTap: () {
                final _state = _sideMenuKey.currentState;
                if (_state.isOpened)
                  _state.closeSideMenu(); // close side menu
                else
                  _state.openSideMenu();

                setState(() {
                  index=0;
                });
              },
              leading: const Icon(Icons.perm_identity_outlined,

                  size: 40.0, color: Colors.black , ),
              title: const Text("Profile" ,style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold , fontSize: 20)),
              // textColor: Colors.white,
              dense: true,

              // padding: EdgeInsets.zero,
            ),
            SizedBox(height: 15,),
            ListTile(
              onTap: () {
                final _state = _sideMenuKey.currentState;
                if (_state.isOpened)
                  _state.closeSideMenu(); // close side menu
                else
                  _state.openSideMenu();

                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Use) );
                setState(() {
                  index=2;
                });

              },
              leading: const Icon(Icons.shopping_cart,
                  size: 40.0, color: Colors.black),
              title: const Text("Cart" , style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold , fontSize: 20)),
              // textColor: Colors.white,
              dense: true,
            ),

            SizedBox(height: 15,),
            ListTile(
              onTap: () {},
              leading:
              const Icon(Icons.logout_outlined, size: 40.0, color: Colors.black),
              title: const Text("Sign Out" , style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold , fontSize: 20)),
              // textColor: Colors.white,
              dense: true,

              // padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      type: SideMenuType.slideNRotate,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.yellow[700],

          leading: GestureDetector(
            onTap: (){
              final _state = _sideMenuKey.currentState;
              if (_state.isOpened)
                _state.closeSideMenu(); // close side menu
              else
                _state.openSideMenu();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: CircleAvatar(
                backgroundColor: Colors.orange[100],
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:isMale? AssetImage(male[image_url]):AssetImage(female[image_url]),
                      fit: BoxFit.contain,
                    ),
                    shape: BoxShape.rectangle,
                  ),
                ),
                radius: 20.0,
              ),
            ),
          ),
          actions: [

            GestureDetector(
              onTap: () {
                print("come on bois");
                print(image);
                print(name);
                print("....");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CartScreen(widget.restaurant_id, widget.user_id,name,image,address,phone_number)));
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "asset/cart_logo.png",
                    ),
                    fit: BoxFit.contain,
                  ),
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
          ],
        ),
        body: index==0 ? Profile(widget.user_id , image_url): (index==1 ? Home(widget.restaurant_id , widget.user_id) : UserRequestHistory()),
        bottomNavigationBar: FancyBottomNavigation(
          tabs: [
            TabData(

                iconData: Icons.perm_identity_outlined,
                title: "Profile"),
            TabData(

                iconData: Icons.home,
                title: "Home"),
            // TabData(iconData: Icons.perm_identity_outlined, title: "Profile"),
            TabData(

                iconData: Icons.history,
                title: "History"),

          ],
          circleColor: Colors.yellow[700],
          inactiveIconColor: Colors.yellow[700],
          onTabChangedListener: (position) {
            setState(() {
              index = position;
            });
          },
        ),
      ),
    );
  }
}

