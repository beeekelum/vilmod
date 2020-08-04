import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vilmod/models/foodItem.dart';

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

//  Future<List<FoodItem>> fetchMenu() async {
//    var url = 'http://192.168.8.106/vilmod/fetch_menu_items.php';
//    var response = await http
//        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
////    http.Response response =
////        await http.get('http://192.168.8.106/vilmod/fetch_menu_items.php');
//    List responseJson = json.decode(response.body);
//    return responseJson.map((m) => new FoodItem.fromJson(m)).toList();
//  }
}
