import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/screens/update_profile_form.dart';
import 'package:vilmod/services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MobileProfile extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  final fs = DatabaseService();

  @override
  Widget build(BuildContext context) {
    void _showSettingsPanel() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Colors.black12,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: UpdateProfileForm(),
          );
        },
      );
    }

    var user = Provider.of<FirebaseUser>(context);
    return StreamBuilder<User>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        var user = snapshot.data;
        if (user != null) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                Container(
                  color: Colors.grey[200],
                  //height: MediaQuery.of(context).size.height,
//                  decoration: BoxDecoration(
//                    image: DecorationImage(
//                        image: AssetImage('assets/images/ll.jpg'),
//                        fit: BoxFit.cover),
//                  ),
                ),
//                Container(
//                  decoration: BoxDecoration(
//                    gradient: LinearGradient(
//                      colors: [
//                        Colors.black.withOpacity(0.4),
//                        Colors.black.withOpacity(0.4),
//                        Colors.black.withOpacity(0.4),
//                      ],
//                      //begin: Alignment.bottomLeft,
//                      begin: Alignment.topCenter,
//                    ),
//                  ),
//                ),
                ListView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 12, top: 20),
                      child: Column(
                        children: <Widget>[
//                          Container(
//                            width: 100,
//                            height: 100,
//                            decoration: BoxDecoration(
//                              image: DecorationImage(
//                                image: NetworkImage(user.photoUrl ?? ''),
//                                fit: BoxFit.fitWidth,
//                                alignment: FractionalOffset.topCenter,
//                              ),
//                              borderRadius: BorderRadius.all(
//                                Radius.circular(90),
//                              ),
////                                boxShadow: [
////                                  BoxShadow(blurRadius: 2, color: Colors.black)
////                                ]
//                            ),
//                          ),
                          _buildProfileImage(user?.photoUrl),
                          SizedBox(
                            height: 10,
                          ),
//                          _makeProfileItem(
//                              'Gender', user.gender ?? '', Icons.people),
                          _makeProfileItem(
                              'First Name', user.firstName ?? '', Icons.person),
                          _makeProfileItem(
                              'Last Name', user.lastName ?? '', Icons.account_box),
                          _makeProfileItem('Email Address',
                              user.emailAddress ?? '', Icons.mail),
                          _makeProfileItem('Phone Number',
                              user.phoneNumber ?? '', Icons.phone),
//                          _makeProfileItem(
//                              'Home Address', user.address, Icons.location_on),
                          Divider(),

                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: <Widget>[
                      FlatButton.icon(
                        onPressed: () => _showSettingsPanel(),
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.green,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  _buildProfileImage(String url) {

    return Container(
      child: CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );

  }


  Padding _makeProfileItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.red[900],
            size: 25,
          ),
          title: Text(
            value,
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins', decoration: TextDecoration.underline,),
          ),
          subtitle: Text(
            title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w100,
                fontFamily: 'Poppins', color: Colors.black38),
          ),
        ),
      ),
    );
  }
}
