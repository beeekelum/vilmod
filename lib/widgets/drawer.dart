import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/components/logo.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/screens/feedback_form.dart';
import 'package:vilmod/screens/notifications.dart';
import 'package:vilmod/services/database.dart';
import 'package:vilmod/utils/routes.dart';

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
              //elevation: 0.0,
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
                        style: TextStyle(fontSize: 17, fontFamily: 'Poppins'),
                      ),
                      accountEmail: Text(
                        user.emailAddress ?? '',
                        style: TextStyle(fontSize: 15, fontFamily: 'Poppins'),
                      ),
                      currentAccountPicture: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(user.photoUrl ?? ''),
                      ),
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
                            fontFamily: 'Poppins'),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          FadePageRoute(
                            builder: (c) {
                              return Notifications();
                            },
                            settings: new RouteSettings(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.chat,
                        color: Colors.red[900],
                      ),
                      title: Text(
                        'Feedback',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins'),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          FadePageRoute(
                            builder: (c) {
                              return FeedbackPage();
                            },
                            settings: new RouteSettings(),
                          ),
                        );
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
                            fontFamily: 'Poppins'),
                      ),
                      onTap: () {
                        //Navigator.pop(context);
                        showAboutDialog(
                            context: context,
                            applicationName: 'VilMod',
                            applicationVersion: '1.0.0',
                            applicationIcon: Logo2(),
                            children: [
                              Text('Amazing meals & a great experience.'),
                              Text(
                                  '115 Paul Kruger street New Court Chamber Pretoria'),
                              Text('073 322 6375/012 342 0608'),
                              Text('vilmodmix@gmail.com'),
                            ],
                            applicationLegalese: 'Copyright © VilMod, 2020');
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
