import 'package:cloud_firestore/cloud_firestore.dart';

class FeedBack {
  String userUid;
  String email;
  String category;
  String title;
  String description;
  String status;
  DateTime dateCreated;
  DocumentReference reference;

  FeedBack(
      {this.userUid,
      this.email,
      this.category,
      this.title,
      this.description,
      this.status,
      this.dateCreated,
      this.reference});

  factory FeedBack.fromSnapshot(DocumentSnapshot snapshot) {
    FeedBack newFeedBack = FeedBack.fromJson(snapshot.data);
    newFeedBack.reference = snapshot.reference;
    return newFeedBack;
  }

  //4
  factory FeedBack.fromJson(Map<dynamic, dynamic> json) =>
      feedbackFromJson(json);

  //5
  Map<String, dynamic> toJson() => feedbackToJson(this);
}

//1
FeedBack feedbackFromJson(Map<dynamic, dynamic> json) {
  return FeedBack(
    userUid: json['userUid'] as String,
    email: json['email'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    description: json['description'] as String,
    status: json['status'] as String,
    dateCreated: json['dateCreated'] == null
        ? null
        : (json['dateCreated'] as Timestamp).toDate(),
  );
}

//2
Map<String, dynamic> feedbackToJson(FeedBack instance) => <String, dynamic>{
      'userUid': instance.userUid,
      'email': instance.email,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'status': instance.status,
      'dateCreated': instance.dateCreated,
    };
