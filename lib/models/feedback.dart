import 'package:cloud_firestore/cloud_firestore.dart';

class FeedBack {
  String userUid;
  String email;
  String title;
  String description;
  DateTime dateCreated;
  DocumentReference reference;

  FeedBack(
      {this.userUid,
      this.email,
      this.title,
      this.description,
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
    title: json['title'] as String,
    description: json['description'] as String,
    dateCreated: json['dateCreated'] == null
        ? null
        : (json['dateCreated'] as Timestamp).toDate(),
  );
}

//2
Map<String, dynamic> feedbackToJson(FeedBack instance) =>
    <String, dynamic>{
      'userUid': instance.userUid,
      'title': instance.title,
      'description': instance.description,
      'dateCreated': instance.dateCreated,
    };