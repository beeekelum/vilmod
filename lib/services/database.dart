import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vilmod/models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  //Collection Reference
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  Future updateUserData(String uid, String firstName, String lastName,
      String emailAddress, String phoneNumber, String photoUrl) async {
    return await userCollection.document(uid).setData({
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl == null
          ? 'https://i.dlpng.com/static/png/6542357_preview.png'
          : photoUrl,
    });
  }

  User _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return User(
        uid: uid ?? '',
        firstName: snapshot.data['firstName'] ?? '',
        lastName: snapshot.data['lastName'],
        emailAddress: snapshot.data['emailAddress'],
        phoneNumber: snapshot.data['phoneNumber'],
        photoUrl: snapshot.data['photoUrl']);
  }

  //get user doc stream
  Stream<User> get userData {
    return userCollection.document(uid).snapshots().map(_userDataFromSnapshot);
  }
}
