import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vilmod/components/logo.dart';

class OrderDetailsPage extends StatefulWidget {
  OrderDetailsPage({this.details});

  final DocumentSnapshot details;

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details: ${widget.details.data['orderNumber']}',
        ),
      ),
      body: Stack(
         children: [
           Container(
             //color: Colors.grey[200],
             //height: MediaQuery.of(context).size.height,
             decoration: BoxDecoration(
               image: DecorationImage(
                   image: AssetImage('assets/images/ll.jpg'),
                   fit: BoxFit.cover),
             ),
           ),
           Container(
             decoration: BoxDecoration(
               gradient: LinearGradient(
                 colors: [
                   Colors.black.withOpacity(.7),
                   Colors.black.withOpacity(.7),
                   Colors.black.withOpacity(.8),
                 ],
                 //begin: Alignment.bottomLeft,
                 begin: Alignment.topCenter,
               ),
             ),
           ),
          Center(
            child: Container(
              //height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Material(
                      elevation: 10,
                      shadowColor: Colors.black,
                      //color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Logo2(),
                          Divider(),
                          orderDetail(
                              'Customer Name: ', widget.details.data['userName']),
                          Divider(),
                          orderDetail(
                              'Order Number: ', widget.details.data['orderNumber']),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left:8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Date Order:'),
                                Text(
                                  DateFormat.yMMMMEEEEd()
                                      .format(widget.details.data['dateOrderCreated'].toDate()),
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left:8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Order Status: ', style: TextStyle(
                                  color: Colors.black,
                                ),),
                                _buildOrderStatus(widget.details.data['orderStatus']),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left:8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Payment Status: ', style: TextStyle(
                                  color: Colors.black,
                                ),),
                                _buildPaymentStatus(widget.details.data['paymentStatus']),
                              ],
                            ),
                          ),
                          for (var item
                          in widget.details.data['orderItems'] ?? [])
                            ListTile(
                              leading: Icon(Icons.radio_button_checked, color: Colors.red[900]),
                              title: Text(
                                item,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                            ),
                          Divider(),
                          orderDetail(
                              'Total Amount paid: ', widget.details.data['orderTotalAmount']),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget orderDetail(String valueName, String value) {
    return Padding(
      padding: const EdgeInsets.only(left:8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            valueName,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _buildPaymentStatus(String status) {
    return Text(
      status,
      style: TextStyle(
          color: status == "Paid" ? Colors.green : Colors.red,
//          fontSize: 11,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline
      ),
    );
  }

  _buildOrderStatus(String status) {
    Color color;
    if(status == 'New'){
      color = Colors.blue;
    } else if(status == 'Being processed'){
      color = Colors.orange;
    } else {
      color = Colors.green;
    }
    return Chip(
      elevation: 0,
      backgroundColor:
      color,
      label: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
