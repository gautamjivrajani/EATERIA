import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class Cart with ChangeNotifier {
  List<Cart> l = [];
  String img_url;
  int count;
  double per_item_price;
  String food_name;
  String item_id;
  String restaurant_id;
  bool isoffline=false;

  Cart({
    String img,
    int count,
    double per_item_price,
    String food_name,
    String restaurant_id,
    String item_id,
  }) {
    this.img_url = img;
    this.count = count;
    this.food_name = food_name;
    this.restaurant_id = restaurant_id;
    this.per_item_price = per_item_price;
    this.item_id = item_id;
  }
  void addItem(
    String img,
    int count,
    double per_item_price,
    String food_name,
    String restaurant_id,
    String item_id,
  ) {
    var c = Cart(
        img: img,
        count: count,
        per_item_price: per_item_price,
        food_name: food_name,
        restaurant_id: restaurant_id,
        item_id: item_id);
    l.add(c);
    notifyListeners();
  }

  void addCount(int index) {
    l[index].count++;
    notifyListeners();
  }

  void minusCount(int index) {
    l[index].count--;
    notifyListeners();
  }

  double GrandTotal() {
    double grand_total = 0;
    double card_count = 0;

    for (int i = 0; i < l.length; i++) {
      card_count = (l[i].count) * (l[i].per_item_price);
      grand_total += card_count;
    }
    return grand_total;
  }

  void delete(int index) {
    l.removeAt(index);
    notifyListeners();
  }

  void deleteAll() {
    l.clear();
    notifyListeners();
  }

  int len() {
    return l.length;
  }
}
