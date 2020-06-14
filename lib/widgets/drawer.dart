import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/services/database.dart';

class AppDrawerVilMod extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  final ds = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return StreamBuilder<User>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          var user = snapshot.data;
          if (user != null) {
            return Drawer(
              elevation: 0.0,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        image: DecorationImage(
                            image: AssetImage("assets/images/food.jpg"),
                            fit: BoxFit.cover),
                      ),
                      accountName: Text(
                        user.firstName + ' ' + user.lastName,
                        style: TextStyle(fontSize: 17, fontFamily: 'OpenSans'),
                      ),
                      accountEmail: Text(
                        user.emailAddress ?? '',
                        style: TextStyle(fontSize: 15, fontFamily: 'OpenSans'),
                      ),
                      currentAccountPicture: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(user.photoUrl ?? ''),
                      ),
                    ),
//                    ListTile(
//                      leading: Icon(
//                        Icons.account_circle,
//                        color: Colors.red[900],
//                      ),
//                      title: Text(
//                        'My Profile',
//                        style: TextStyle(
//                            fontSize: 15.0,
//                            fontWeight: FontWeight.w500,
//                            fontFamily: 'OpenSans'),
//                      ),
//                      onTap: () {
//                        Navigator.pop(context);
////                        Navigator.of(context).push(
////                          FadePageRoute(
////                            builder: (c) {
////                              return MobileProfile();
////                            },
////                            settings: new RouteSettings(),
////                          ),
////                        );
//                      },
//                    ),
//                    ListTile(
//                      leading: Icon(
//                        FontAwesomeIcons.calendarAlt,
//                        color: Colors.red[900],
//                      ),
//                      title: Text(
//                        'My Orders',
//                        style: TextStyle(
//                            fontSize: 15.0,
//                            fontWeight: FontWeight.w500,
//                            fontFamily: 'OpenSans'),
//                      ),
//                      onTap: () {
////                        Navigator.pop(context);
////                        Navigator.of(context).push(
////                          FadePageRoute(
////                            builder: (c) {
////                              return UserBookedTicketsStatus();
////                            },
////                            settings: new RouteSettings(),
////                          ),
////                        );
//                      },
//                    ),
                    ListTile(
                      leading: Icon(
                        Icons.history,
                        color: Colors.red[900],
                      ),
                      title: Text(
                        'History',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'OpenSans'),
                      ),
                      onTap: () {
//                        Navigator.pop(context);
//                        Navigator.of(context).push(
//                          FadePageRoute(
//                            builder: (c) {
//                              return ProfilePage();
//                            },
//                            settings: new RouteSettings(),
//                          ),
//                        );
                      },
                    ),

                    ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: Colors.red[900],
                      ),
                      title: Text(
                        'Notifications',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'OpenSans'),
                      ),
                      onTap: () {
//                        Navigator.pop(context);
//                        Navigator.of(context).push(
//                          FadePageRoute(
//                            builder: (c) {
//                              return ProfilePage();
//                            },
//                            settings: new RouteSettings(),
//                          ),
//                        );
                      },
                    ),
//                    ListTile(
//                      leading: Icon(
//                        Icons.contacts,
//                        color: Colors.red[900],
//                      ),
//                      title: Text(
//                        'Emergency Contact',
//                        style: TextStyle(
//                            fontSize: 15.0,
//                            fontWeight: FontWeight.w500,
//                            fontFamily: 'OpenSans'),
//                      ),
//                      onTap: () {
////                        Navigator.pop(context);
////                        Navigator.of(context).push(
////                          FadePageRoute(
////                            builder: (c) {
////                              return ProfilePage();
////                            },
////                            settings: new RouteSettings(),
////                          ),
////                        );
//                      },
//                    ),
                    ListTile(
                      leading: Icon(
                        Icons.chat,
                        color: Colors.red[900],
                      ),
                      title: Text(
                        'User Feedback',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'OpenSans'),
                      ),
                      onTap: () {
//                        Navigator.pop(context);
//                        Navigator.of(context).push(
//                          FadePageRoute(
//                            builder: (c) {
//                              return ProfilePage();
//                            },
//                            settings: new RouteSettings(),
//                          ),
//                        );
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        FontAwesomeIcons.infoCircle,
                        color: Colors.red[900],
                      ),
                      title: Text(
                        'About VilMod',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'OpenSans'),
                      ),
                      onTap: () {
//                        Navigator.pop(context);
//                        Navigator.of(context).push(
//                          FadePageRoute(
//                            builder: (c) {
//                              return AboutHomestay();
//                            },
//                            settings: new RouteSettings(),
//                          ),
//                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
