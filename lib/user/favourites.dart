import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Favourites extends StatefulWidget {
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  var allData;
  int i = 0;

  Future<void> getData() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('admin_details_items');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (int i = 0; i < allData.length; i++) {
      Map<dynamic, dynamic> m = allData[i];
      // print(m.keys.first);
      print(m.values.first['liked']);
    }

    setState(() {
      i = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    getData();

    return GridView.builder(
      itemBuilder: (context, index) {
        return allData[index]['liked'] == false
            ? Center(
                child: Text("Nothing to Show"),
              )
            : Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                margin: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Image.network(
                            allData[index]['image'],
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 10,
                          child: Container(
                            width: 300,
                            color: Colors.black54,
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 20,
                            ),
                            child: Text(
                              allData[index]['name'],
                              style: TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        )
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        // topLeft: Radius.circular(15),
                        // topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: [Colors.yellow[100], Colors.yellow[100]]),
                          // shape: BoxShape.,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        "https://cdn-icons-png.flaticon.com/128/6779/6779071.png",
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                    shape: BoxShape.rectangle,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            "https://cdn-icons-png.flaticon.com/128/1490/1490817.png"),
                                        fit: BoxFit.contain),
                                    shape: BoxShape.rectangle,
                                    // border:
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                // Text('${allData[index]['price']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 2,
    );
  }
}
