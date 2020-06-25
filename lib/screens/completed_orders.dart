//import 'package:flutter/material.dart';
//
//class CompletedOrders extends StatefulWidget {
//  @override
//  _CompletedOrdersState createState() => _CompletedOrdersState();
//}
//
//class _CompletedOrdersState extends State<CompletedOrders> {
//  @override
//  Widget build(BuildContext context) {
//    return Container();
//  }
//}
//
//
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/screens/my_order_details.dart';
import 'package:vilmod/services/database.dart';
import 'package:vilmod/services/order_service.dart';
import 'package:vilmod/utils/routes.dart';

class CompletedOrders extends StatelessWidget {
  final CollectionReference collectionReference =
  Firestore.instance.collection('orders');

  Future<String> _getUserProfilePicById(id) async {
    return Firestore.instance
        .collection('users')
        .document(id)
        .get()
        .then((docSnap) {
      var profilePic = docSnap['photoUrl'];
      return profilePic;
    });
  }

  @override
  Widget build(BuildContext context) {
    var fUser = Provider.of<FirebaseUser>(context);
    return StreamBuilder<User>(
        stream: DatabaseService(uid: fUser?.uid).userData,
        builder: (context, snapshot) {
          var user = snapshot.data;
          return Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/food.jpg'),
                      fit: BoxFit.cover),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.7),
                    ],
                    //begin: Alignment.bottomLeft,
                    begin: Alignment.topCenter,
                  ),
                ),
              ),
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: collectionReference.where('orderStatus', isEqualTo: 'Completed').where('userUid', isEqualTo: user?.uid).snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) return new Text('${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "No Orders!",
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white),
                              ),
                            ),
                          ),
                        );

                      default:
                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            final item = snapshot.data.documents[index];
                            return GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Material(
                                  elevation: 10,
                                  shadowColor: Colors.red[900],
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Text(
                                              DateFormat.yMMMMEEEEd()
                                                  .format(
                                                  item['dateOrderCreated']
                                                      .toDate()),
                                              style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                            Text(
                                              DateFormat.jm().format(
                                                  item['dateOrderCreated']
                                                      .toDate()),
                                              style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        ListTile(
                                          leading: _buildProfileImage(
                                              item['userUid']) ??
                                              '',
                                          title: Text(
                                            'Order#: ' +
                                                item['orderNumber'], style: TextStyle(),
                                          ),
                                          subtitle: Row(
                                            children: <Widget>[
                                              Text(
                                                'Total: ',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                                              ),
                                              Text(
                                                '${item['orderTotalAmount']}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          trailing: _buildOrderStatus(
                                              item['orderStatus']),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                FlatButton.icon(
                                                  color: Colors.grey[300],
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      new FadePageRoute(
                                                        builder: (c) {
                                                          return OrderDetailsPage(
                                                              details: snapshot
                                                                  .data
                                                                  .documents[
                                                              index]
                                                          );
                                                        },
                                                        settings:
                                                        new RouteSettings(),
                                                      ),
                                                    );
                                                  },
                                                  shape:
                                                  new RoundedRectangleBorder(
                                                      borderRadius:
                                                      new BorderRadius
                                                          .circular(
                                                          30.0)),
                                                  label: Text(
                                                    'View Order Details',
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                  icon: Icon(
                                                      Icons.search),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                    }
                  },
                ),
              ),
            ],
          );
        });
  }

  _buildOrderStatus(String status) {
    return Chip(
      elevation: 2,
      backgroundColor:
      status == "Completed" ? Colors.green : Colors.orange,
      label: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _buildProfileImage(String uid) {

    return Container(
      child: CachedNetworkImage(
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/vilmod-534db.appspot.com/o/villogo.png?alt=media&token=2b230ad0-b5db-4aa3-8b67-33a85bc590a5',
        imageBuilder: (context, imageProvider) => Container(
          width: 40.0,
          height: 40.0,
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
}

