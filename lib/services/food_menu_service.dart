import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vilmod/models/foodItem.dart';
import 'package:http/http.dart' as http;

class FoodMenuServices {
  final Firestore _db = Firestore.instance;

  Future<QuerySnapshot> getDataCollection() {
    var ref = _db.collection('menu');
    return ref.getDocuments();
  }

//  Stream<QuerySnapshot> streamDataCollection() {
//    var ref = _db.collection('menu');
//    return ref.snapshots();
//  }

  Stream<List<FoodItem>> streamFoodItems(String menuType) {
    String fieldName;
    if(menuType == 'Deal'){
      fieldName = 'isDeal';
    }else {
      fieldName = 'foodItemCategory';
    }
    var ref =
        _db.collection('menu').where(fieldName, isEqualTo: menuType).where('status', isEqualTo: 'Available');

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => FoodItem.fromFirestore(doc)).toList());
  }

  Future<List<FoodItem>> fetchMenu(String menuType) async {
    var url = 'http://64.227.18.73:3000/api/v1/meals';
//    var response = await http
//        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    //print(response.body);
    http.Response response =
        await http.get('http://64.227.18.73:3000/api/v1/meals');
    List responseJson = json.decode(response.body);
    print(responseJson);
    return responseJson.map((m) => new FoodItem.fromJson(m)).toList();
  }
}
