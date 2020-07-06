import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vilmod/models/notification.dart';

class NotificationService{
  static final Firestore _db = Firestore.instance;

  static final CollectionReference notificationCollection = _db.collection('notifications');

  Stream<QuerySnapshot> getNotificationsStream(String userUid) {
    return notificationCollection.where('userUid', isEqualTo: userUid).snapshots();
  }

  Future<void> addNotification(OrderNotification notification) {
    return notificationCollection.add(notification.toJson());
  }
}