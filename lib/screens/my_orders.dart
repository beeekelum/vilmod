import 'package:flutter/material.dart';
import 'package:vilmod/screens/completed_orders.dart';
import 'package:vilmod/screens/pending_new_orders.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: new Container(
              color: Colors.red[900],
              child: new SafeArea(
                child: Column(
                  children: <Widget>[
                    new Expanded(child: new Container()),
                    new TabBar(
                      tabs: [
                        Tab(text: 'New Pending Orders'),
                        Tab(text: 'Completed Orders',),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              OrdersPending(),
              CompletedOrders(),
            ],
          ),
        ),
      ),
    );
  }
}
