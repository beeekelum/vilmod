import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoodItemList {
  List<FoodItem> foodItems;

  FoodItemList({@required this.foodItems});
}

class FoodItem {
  //String docID;
  var id;
  var foodItemName;
  var foodItemImage;
  var foodItemPrice;
  var foodItemDescription;
  var foodItemCategory;
  var isDeal;

  //DateTime dateCreated;
  var quantity;

  FoodItem(
      {
      //this.docID,
      @required this.id,
      @required this.foodItemName,
      @required this.foodItemImage,
      @required this.foodItemPrice,
      @required this.foodItemDescription,
      @required this.foodItemCategory,
      @required this.isDeal,
      //@required this.dateCreated,
      this.quantity = 1});

  void incrementQuantity() {
    this.quantity = this.quantity + 1;
  }

  void decrementQuantity() {
    this.quantity = this.quantity - 1;
  }

  FoodItem.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        foodItemName = parsedJson['foodItemName'],
        foodItemPrice = parsedJson['foodItemPrice'],
        foodItemDescription = parsedJson['foodItemDescription'],
        foodItemCategory = parsedJson['foodItemCategory'],
        isDeal = parsedJson['isDeal'];

  //dateCreated = parsedJson['dateCreated'];

  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return FoodItem(
      id: data['id'] ?? '',
      foodItemName: data['foodItemName'] ?? '',
      foodItemImage: data['foodItemImage'] ?? '',
      foodItemPrice: data['foodItemPrice'] ?? '',
      foodItemDescription: data['foodItemDescription'] ?? '',
      foodItemCategory: data['foodItemCategory'] ?? '',
      isDeal: data['isDeal'] ?? '',
      //id: data[''] ?? '',
    );
  }

  FoodItem.fromMap(Map snapshot, String id)
      : id = snapshot['id'] ?? '',
        foodItemName = snapshot['foodItemName'] ?? '',
        foodItemImage = snapshot['foodItemImage'] ?? '',
        foodItemPrice = snapshot['foodItemPrice'] ?? '',
        foodItemDescription = snapshot['foodItemDescription'] ?? '',
        foodItemCategory = snapshot['foodItemCategory'] ?? '',
        isDeal = snapshot['isDeal'] ?? '';

  Map toJson() {
    return {
      "id": id,
      "foodItemName": foodItemName,
      "foodItemImage": foodItemImage,
      "foodItemPrice": foodItemPrice,
      "foodItemDescription": foodItemDescription,
      "foodItemCategory": foodItemCategory,
      "isDeal": isDeal
    };
  }
}
