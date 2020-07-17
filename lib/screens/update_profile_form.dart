import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/components/constants.dart';
import 'package:vilmod/components/loading.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/services/database.dart';
import 'package:flushbar/flushbar.dart';

class UpdateProfileForm extends StatefulWidget {
  @override
  _UpdateProfileFormState createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<UpdateProfileForm> {
  final _formKey = GlobalKey<FormState>();

  //form values
  String _currentFirstName;
  String _currentLastName;
  String _currentPhoneNumber;
  String _currentEmailAddress;
  String imageUrl = '';

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future uploadPic() async {
    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/get-a-guard.appspot.com/o/$_image?alt=media';
    setState(() {
      print('Profile picture updated successfully');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamBuilder<User>(
        stream: DatabaseService(uid: user?.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User userData = snapshot.data;
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.red[900],
                            child: ClipOval(
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: (_image != null)
                                    ? Image.file(
                                        _image,
                                        fit: BoxFit.fitWidth,
                                        alignment: FractionalOffset.center,
                                      )
                                    : Image.network(userData.photoUrl ?? ''),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.camera,
                              color: Colors.black45,
                            ),
                            onPressed: () {
                              getImage();
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Update your profile',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        initialValue: userData.firstName,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'First name'),
                        validator: (value) =>
                            value.isEmpty ? 'Please enter first name' : null,
                        onChanged: (value) =>
                            setState(() => _currentFirstName = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        initialValue: userData.lastName,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Last name'),
                        validator: (value) =>
                            value.isEmpty ? 'Please enter last name' : null,
                        onChanged: (value) =>
                            setState(() => _currentLastName = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        initialValue: userData.phoneNumber,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Phone number'),
                        validator: (value) =>
                            value.isEmpty ? 'Please enter phone number' : null,
                        onChanged: (value) =>
                            setState(() => _currentPhoneNumber = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        initialValue: userData.emailAddress,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Email address'),
                        validator: (value) =>
                            value.isEmpty ? 'Please enter email address' : null,
                        onChanged: (value) =>
                            setState(() => _currentEmailAddress = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 200,
                        height: 50,
                        child: RaisedButton(
                          color: Colors.red[900],
                          elevation: 0,
                          child: Text(
                            "Update",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (_image == null) {
                                await DatabaseService(uid: user?.uid)
                                    .updateUserData(
                                        userData.uid,
                                        _currentFirstName ?? userData.firstName,
                                        _currentLastName ?? userData.lastName,
                                        _currentEmailAddress ??
                                            userData.emailAddress,
                                        _currentPhoneNumber ??
                                            userData.phoneNumber,
                                        userData.photoUrl,
                                        'User' ?? userData.userType);
                                Navigator.pop(context);
                              } else {
                                String imageExt = basename(_image.path)
                                        .split('.')[
                                    basename(_image.path).split('.').length -
                                        1];
                                var rng = new Random();
                                var code = rng.nextInt(900000) + 100000;
                                String fileName = '${code}.$imageExt';
                                //print(fileName);
                                StorageReference firebaseStorageRef =
                                    FirebaseStorage.instance
                                        .ref()
                                        .child('VilmodProfilePics')
                                        .child(fileName);
                                StorageUploadTask uploadTask =
                                    firebaseStorageRef.putFile(_image);
                                StorageTaskSnapshot storageTaskSnapshot =
                                    await uploadTask.onComplete;
                                String downloadUrl = await firebaseStorageRef
                                    .getDownloadURL()
                                    .then((img) async {
                                  return await DatabaseService(uid: user.uid)
                                      .updateUserData(
                                          userData.uid,
                                          _currentFirstName ??
                                              userData.firstName,
                                          _currentLastName ?? userData.lastName,
                                          _currentEmailAddress ??
                                              userData.emailAddress,
                                          _currentPhoneNumber ??
                                              userData.phoneNumber,
                                          img ?? userData.photoUrl,
                                          'User' ?? userData.userType);
                                });
                               // Navigator.pop(context);
                                showFloatingFlushBar(context);
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Loading();
          }
        });
  }

  void showFloatingFlushBar(BuildContext context) {
    Flushbar(
      //aroundPadding: EdgeInsets.all(10),
      borderRadius: 10,
      backgroundGradient: LinearGradient(
        colors: [Colors.green.shade900, Colors.green.shade600],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      duration: Duration(milliseconds: 1500),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(
        Icons.add_shopping_cart,
        color: Colors.white,
      ),
      shouldIconPulse: true,
      title: 'Profile edited successfully',
      //message: 'Thank you for the feedback.',
    )..show(context).then(
        (value) => Navigator.pop(context)
//            Navigator.of(context).pushNamedAndRemoveUntil(
//            '/home_page', (Route<dynamic> route) => false),
      );
  }
}
