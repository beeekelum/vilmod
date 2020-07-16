//import 'package:flutter/material.dart';
//
//class Notifications extends StatefulWidget {
//  @override
//  _NotificationsState createState() => _NotificationsState();
//}
//
//class _NotificationsState extends State<Notifications> {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: Text('My Notifications'),),
//    );
//  }
//}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Notifications extends StatelessWidget {
  final CollectionReference collectionReference =
      Firestore.instance.collection('notifications');

  @override
  Widget build(BuildContext context) {
    var fUser = Provider.of<FirebaseUser>(context);
    return StreamBuilder<User>(
        stream: DatabaseService(uid: fUser?.uid).userData,
        builder: (context, snapshot) {
          var user = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text('Order Notifications'),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Container(
                child: StreamBuilder<QuerySnapshot>(
                    stream: collectionReference
                        .where('userUid', isEqualTo: user?.uid)
                        .orderBy('dateCreated', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return new Text('${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "No Notifications.",
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.black),
                                ),
                              ),
                            ),
                          );

                        default:
                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              final item = snapshot.data.documents[index];
                              return GestureDetector(
                                onTap: () {},
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    //Divider(),
                                    ListTile(
                                      isThreeLine: false,
                                      leading: Icon(Icons.receipt,color: Colors.red[900],),
                                      title: Text(item['title'], style: TextStyle(),),
                                      subtitle: Text(
                                        item['body'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Column(
                                        children: <Widget>[
                                          Text(
                                            DateFormat.yMMMMEEEEd().format(
                                                item['dateCreated'].toDate()),
                                            style: TextStyle(

                                                fontSize: 12, color: Colors.black45),
                                          ),
                                          Text(
                                            DateFormat.jm().format(
                                                item['dateCreated'].toDate()),
                                            style: TextStyle(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider()
                                  ],
                                ),
                              );
                            },
                          );
                      }
                    }),
              ),
            ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {},
//        child: Icon(
//          Icons.add,
//          color: Colors.red,
//        ),
//        backgroundColor: Colors.white,
//      ),
          );
        });
  }

  Widget _listItem(int i) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(i.toString()),
        backgroundColor: Colors.green,
      ),
      title: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "shogo.yamada",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "8:59",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            "Please Subscribe this channel!!!!! Please!!!!!",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("this is gmail app using flutter !!!!!"),
          Icon(Icons.star_border)
        ],
      ),
    );
  }
}
