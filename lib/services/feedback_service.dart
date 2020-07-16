import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vilmod/models/feedback.dart';

class FeedbackService {
  static final Firestore _db = Firestore.instance;

  static final CollectionReference feedbackCollection = _db.collection('feedback');

//  Stream<QuerySnapshot> getNotificationsStream(String userUid) {
//    return feedbackCollection.where('userUid', isEqualTo: userUid).snapshots();
//  }

  Future<void> addFeedback(FeedBack feedBack) {
    return feedbackCollection.add(feedBack.toJson());
  }
}