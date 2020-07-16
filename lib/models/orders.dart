import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  String orderNumber;
  String userUid;
  String userName;
  String userPhoneNumber;
  String userAddress;
  String userEmail;
  DateTime dateOrderCreated;
  var orderItems;
  String orderTotalAmount;
  int tAmount;
  String flag;
  String orderStatus;
  String paymentStatus;
  DocumentReference reference;

  Order(
      {this.orderNumber,
      this.userUid,
      this.userName,
      this.userPhoneNumber,
      this.userAddress,
      this.userEmail,
      this.dateOrderCreated,
      this.orderItems,
      this.orderTotalAmount,
      this.tAmount,
      this.flag,
      this.orderStatus,
      this.paymentStatus,
      this.reference});

  factory Order.fromSnapshot(DocumentSnapshot snapshot) {
    Order newOrder = Order.fromJson(snapshot.data);
    newOrder.reference = snapshot.reference;
    return newOrder;
  }

  //4
  factory Order.fromJson(Map<dynamic, dynamic> json) => orderFromJson(json);

  //5
  Map<String, dynamic> toJson() => orderToJson(this);
}

//1
Order orderFromJson(Map<dynamic, dynamic> json) {
  return Order(
    orderNumber: json['orderNumber'] as String,
    userUid: json['userUid'] as String,
    userName: json['userName'] as String,
    userPhoneNumber: json['userPhoneNumber'] as String,
    userAddress: json['userAddress'] as String,
    userEmail: json['userEmail'] as String,
    dateOrderCreated: json['dateOrderCreated'] == null
        ? null
        : (json['dateOrderCreated'] as Timestamp).toDate(),
    orderItems: json['orderItems'] as List,
    orderTotalAmount: json['orderTotalAmount'] as String,
    tAmount: json['tAmount'] as int,
    flag: json['flag'] as String,
    orderStatus: json['orderStatus'] as String,
    paymentStatus: json['paymentStatus'] as String,
  );
}

//2
Map<String, dynamic> orderToJson(Order instance) => <String, dynamic>{
      'orderNumber': instance.orderNumber,
      'userUid': instance.userUid,
      'userName': instance.userName,
      'userPhoneNumber': instance.userPhoneNumber,
      'userAddress': instance.userAddress,
      'userEmail': instance.userEmail,
      'dateOrderCreated': instance.dateOrderCreated,
      'orderItems': instance.orderItems,
      'orderTotalAmount': instance.orderTotalAmount,
      'tAmount': instance.tAmount,
      'flag': instance.flag,
      'orderStatus': instance.orderStatus,
      'paymentStatus': instance.paymentStatus,
    };
