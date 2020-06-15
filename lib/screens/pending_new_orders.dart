import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/services/database.dart';
import 'package:vilmod/services/order_service.dart';
import 'package:vilmod/utils/routes.dart';

class OrdersPending extends StatelessWidget {
  final CollectionReference collectionReference =
  Firestore.instance.collection('orders');

//  void updateBookingStatus(BuildContext context) {
//    Flushbar(
//      flushbarPosition: FlushbarPosition.TOP,
//      flushbarStyle: FlushbarStyle.FLOATING,
//      borderRadius: 10,
//      reverseAnimationCurve: Curves.decelerate,
//      forwardAnimationCurve: Curves.elasticOut,
//      backgroundColor: Colors.green,
//      backgroundGradient: LinearGradient(
//        colors: [Colors.green.shade800, Colors.green.shade600],
//        stops: [0.6, 1],
//      ),
//      isDismissible: false,
//      duration: Duration(seconds: 3),
//      icon: Icon(
//        Icons.check,
//        color: Colors.greenAccent,
//      ),
//      mainButton: FlatButton(
//        onPressed: () {},
//        child: Text(
//          "OK",
//          style: TextStyle(color: Colors.yellow[500]),
//        ),
//      ),
//      showProgressIndicator: true,
//      progressIndicatorBackgroundColor: Colors.blueGrey,
//      titleText: Text(
//        "Donation Confirmed",
//        style: TextStyle(
//            fontWeight: FontWeight.bold,
//            fontSize: 20.0,
//            color: Colors.yellow[600],
//            fontFamily: "ShadowsIntoLightTwo"),
//      ),
//      messageText: Text(
//        "Donation has been successfuly matched with paypal payment records",
//        style: TextStyle(
//            fontSize: 18.0,
//            color: Colors.white,
//            fontFamily: "ShadowsIntoLightTwo"),
//      ),
//    ).show(context);
//  }

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
    print(fUser.uid);
    return StreamBuilder<User>(
        stream: DatabaseService(uid: fUser?.uid).userData,
        builder: (context, snapshot) {
          var user = snapshot.data;
          return Stack(
            children: <Widget>[
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: OrderService().getOrdersStream(user.uid),
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
                                  elevation: 5,
                                  shadowColor: Colors.black,
                                  color: Colors.white,
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
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              ],
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        ListTile(
                                          leading: _buildProfileImage(
                                              item['userUid']) ??
                                              '',
                                          title: Text(
                                            'Order #: ' +
                                                item['orderNumber'],
                                          ),
                                          subtitle: Row(
                                            children: <Widget>[
                                              Text(
                                                'Order: ',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                '${item['orderTotalAmount']}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
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
//                                                    Navigator.of(context).push(
//                                                      new FadePageRoute(
//                                                        builder: (c) {
//                                                          return OrderDetailsPage(
//                                                              user: snapshot
//                                                                  .data
//                                                                  .documents[
//                                                              index]
//                                                          );
//                                                        },
//                                                        settings:
//                                                        new RouteSettings(),
//                                                      ),
//                                                    );
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
                                                      Icons.remove_red_eye),
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
      elevation: 5,
      backgroundColor:
      status == "New" ? Colors.blue[700] : Colors.green,
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
    return FutureBuilder(
      future: _getUserProfilePicById(uid),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) return Text('');
        final String userID = snapshot.data;
        return Container(
          child: CachedNetworkImage(
            imageUrl: snapshot.data,
            imageBuilder: (context, imageProvider) => Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      },
    );
  }
}

class OrderDetailsPage {
}
