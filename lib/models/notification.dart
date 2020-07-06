import 'package:cloud_firestore/cloud_firestore.dart';

class OrderNotification {
 // String notificationId;
  String userUid;
  String title;
  String body;
  bool isRead;
  String orderNumber;
  DateTime dateCreated;
  DocumentReference reference;

  OrderNotification(
      {
        //this.notificationId,
      this.userUid,
      this.title,
      this.body,
      this.isRead,
      this.orderNumber,
      this.dateCreated,
      this.reference});

  factory OrderNotification.fromSnapshot(DocumentSnapshot snapshot) {
    OrderNotification newOrderNotification = OrderNotification.fromJson(snapshot.data);
    newOrderNotification.reference = snapshot.reference;
    return newOrderNotification;
  }

  //4
  factory OrderNotification.fromJson(Map<dynamic, dynamic> json) =>
      notificationFromJson(json);

  //5
  Map<String, dynamic> toJson() => notificationToJson(this);
}

//1
OrderNotification notificationFromJson(Map<dynamic, dynamic> json) {
  return OrderNotification(
    //notificationId: json['notificationId'] as String,
    userUid: json['userUid'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    isRead: json['isRead'] as bool,
    orderNumber: json['orderNumber'] as String,
    dateCreated: json['dateCreated'] == null
        ? null
        : (json['dateCreated'] as Timestamp).toDate(),
  );
}

//2
Map<String, dynamic> notificationToJson(OrderNotification instance) =>
    <String, dynamic>{
      //'notificationId': instance.notificationId,
      'userUid': instance.userUid,
      'title': instance.title,
      'body': instance.body,
      'isRead': instance.isRead,
      'orderNumber': instance.orderNumber,
      'dateCreated': instance.dateCreated,
    };
