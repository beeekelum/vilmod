import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vilmod/models/orders.dart';

class OrderService {
  static final Firestore _db = Firestore.instance;

  static final CollectionReference orderCollection = _db.collection('orders');

  Stream<QuerySnapshot> getOrdersStream(String userUid) {
    return orderCollection.where('userUid', isEqualTo: userUid).snapshots();
  }

  Future<DocumentReference> addOrder(Order order) {
    return orderCollection.add(order.toJson());
  }
}