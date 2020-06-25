import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vilmod/bloc/cartlist_bloc.dart';
import 'package:vilmod/bloc/list_style_color_bloc.dart';
import 'package:vilmod/components/logo.dart';
import 'package:vilmod/models/foodItem.dart';
import 'package:vilmod/models/orders.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/screens/notifications.dart';
import 'package:vilmod/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:vilmod/services/order_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Cart extends StatelessWidget {
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  @override
  Widget build(BuildContext context) {
    List<FoodItem> foodItems;
    return StreamBuilder(
      stream: bloc.listStream,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          foodItems = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'My Cart',
                style: TextStyle(fontFamily: 'Amita'),
              ),
              actions: <Widget>[_shoppingCartBadge(foodItems.length)],
              elevation: 0,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: CartBody(foodItems),
                ),
              ),
            ),
            bottomNavigationBar: BottomBar(foodItems),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _shoppingCartBadge(int itemsCount) {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      badgeColor: Colors.green,
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        itemsCount.toString(),
        style: TextStyle(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
      ),
    );
  }
}

class BottomBar extends StatefulWidget {
  final List<FoodItem> foodItems;

  BottomBar(this.foodItems);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final OrderService orderService = OrderService();
  static final String tokenizationKey = 'sandbox_8hxpnkht_kzdtzv2btm4p7s5j';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid;

  var initializationSettingsIOS;

  var initializationSettings;

  void _showNotification() async {
    await _demoNotification();
  }

  Future<void> _demoNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, 'Vilmod Restaurant',
        'Thank you. New Order Created', platformChannelSpecifics,
        payload: 'test payload');
  }

  @override
  void initState() {
    super.initState();
    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => new Notifications()));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Notifications()));
                  },
                )
              ],
            ));
  }

  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          totalAmount(widget.foodItems),
          nextButtonBar(context),
        ],
      ),
    );
  }

  Widget nextButtonBar(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var orderNumber = Random().nextInt(900000) + 100000;
    void showNonce(BraintreePaymentMethodNonce nonce) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Payment method nonce:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Nonce: ${nonce.nonce}'),
              SizedBox(height: 16),
              Text('Type label: ${nonce.typeLabel}'),
              SizedBox(height: 16),
              Text('Description: ${nonce.description}'),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          var user = snapshot.data;
          return GestureDetector(
            onTap: () {
              showGeneralDialog(
                context: context,
                barrierColor: Colors.black12.withOpacity(0.6),
                // background color
                barrierDismissible: false,
                // should dialog be dismissed when tapped outside
                barrierLabel: "Dialog",
                // label for barrier
                transitionDuration: Duration(milliseconds: 400),
                // how long it takes to popup dialog after button click
                pageBuilder: (_, __, ___) {
                  // your widget implementation
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(
                        'Confirm Order',
                        style: TextStyle(fontFamily: 'Amita'),
                      ),
                    ),
                    body: SizedBox.expand(
                      // makes widget fullscreen
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Container(
                                //height: MediaQuery.of(context).size.height,
                                decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    colorFilter: new ColorFilter.mode(
                                        Colors.white.withOpacity(0.03),
                                        BlendMode.dstATop),
                                    image: new AssetImage(
                                      'assets/images/logo1.png',
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Logo(),
                                      _buildItem('Full Name:',
                                          '${user.firstName + ' ' + user.lastName}'),
                                      Divider(),
                                      _buildItem('Email:', user.emailAddress),
                                      Divider(),
                                      _buildItem(
                                          'Phone Number:', user.phoneNumber),
                                      Divider(),
                                      _buildItem('Items Ordered:',
                                          widget.foodItems.length.toString()),
                                      Divider(),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: widget.foodItems
                                            .map((item) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 12.0,
                                                          right: 12,
                                                          top: 4,
                                                          bottom: 4),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                              '${item.quantity.toString()} X '),
                                                          Container(
                                                            width: 200,
                                                            child: Text(
                                                              item.foodItemName,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                          'R${item.foodItemPrice.toString()}'),
                                                      Text(
                                                        'R${(item.quantity * item.foodItemPrice).toString()}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            '\R${returnTotalAmount(widget.foodItems)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 25),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox.expand(
                              child: StreamBuilder(
                                  stream: bloc.listStream,
                                  builder: (context, snapshot) {
                                    List<FoodItem> foodItems = snapshot.data;
                                    return RaisedButton(
                                      color: Colors.red[900],
                                      child: Text(
                                        "Pay Now",
                                        style: TextStyle(fontSize: 30),
                                      ),
                                      textColor: Colors.white,
                                      onPressed: () async {
                                        List<String> order = new List<String>();
                                        int totalAmount = 0;

                                        for (int i = 0;
                                            i < widget.foodItems.length;
                                            i++) {
                                          int itemTotal = widget
                                                  .foodItems[i].quantity *
                                              widget.foodItems[i].foodItemPrice;
                                          totalAmount = totalAmount +
                                              widget.foodItems[i].quantity *
                                                  widget.foodItems[i]
                                                      .foodItemPrice;
                                          ;
                                          order.add(widget.foodItems[i].quantity
                                                  .toString() +
                                              " x " +
                                              widget.foodItems[i].foodItemName +
                                              " = R" +
                                              itemTotal.toString());
                                        }
                                        Order newOrder = Order(
                                            orderNumber:
                                                'VR${orderNumber.toString()}',
                                            userUid: user.uid,
                                            userName:
                                                '${user.firstName + ' ' + user.lastName}',
                                            userPhoneNumber: user.phoneNumber,
                                            userAddress: '',
                                            userEmail: user.emailAddress,
                                            dateOrderCreated: DateTime.now(),
                                            orderItems: order,
                                            orderTotalAmount:
                                                'R${totalAmount.toString()}',
                                            orderStatus: 'New',
                                            paymentStatus: 'Pending');
                                        orderService.addOrder(newOrder);
                                        _showNotification();
                                        foodItems.clear();
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil('/home_page', (Route<dynamic> route) => false);
//                                        var request = BraintreeDropInRequest(
//                                          tokenizationKey: tokenizationKey,
//                                          collectDeviceData: true,
//                                          googlePaymentRequest:
//                                              BraintreeGooglePaymentRequest(
//                                            totalPrice: '4.20',
//                                            currencyCode: 'USD',
//                                            billingAddressRequired: false,
//                                          ),
//                                          paypalRequest: BraintreePayPalRequest(
//                                            amount: '4.20',
//                                            displayName: 'Vilmod Restaurant',
//                                          ),
//                                        );
//                                        BraintreeDropInResult result =
//                                            await BraintreeDropIn.start(request)
//                                                .then((value) => Navigator.of(
//                                                        context)
//                                                    .pushNamedAndRemoveUntil(
//                                                        '/home_page',
//                                                        (Route<dynamic>
//                                                                route) =>
//                                                            false));
//                                        if (result != null) {
//                                          showNonce(result.paymentMethodNonce);
//                                        }
                                      },
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 50, left: 50),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xfffeb324),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Checkout',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildItem(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(key),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Container totalAmount(List<FoodItem> foodItem) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Total:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(20),
            shadowColor: Colors.black.withOpacity(.9),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                '\R${returnTotalAmount(widget.foodItems)}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String returnTotalAmount(List<FoodItem> foodItems) {
    double totalAmount = 0.0;

    for (int i = 0; i < foodItems.length; i++) {
      totalAmount =
          totalAmount + foodItems[i].foodItemPrice * foodItems[i].quantity;
    }

    return totalAmount.toStringAsFixed(2);
  }
}

class CartBody extends StatelessWidget {
  final List<FoodItem> foodItems;

  CartBody(this.foodItems);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
        child: Column(
          children: <Widget>[
            //CustomAppBar(),
            title(),
            Expanded(
              flex: 1,
              child: foodItems.length > 0 ? foodItemList() : noItemContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Container noItemContainer() {
    return Container(
      child: Center(
        child: Text(
          'No more items left in the cart',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              fontSize: 20),
        ),
      ),
    );
  }

  ListView foodItemList() {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: foodItems.length,
        itemBuilder: (builder, index) {
          return CartListItem(foodItem: foodItems[index]);
        });
  }

  Widget title() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'My Order',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartListItem extends StatelessWidget {
  final FoodItem foodItem;

  CartListItem({@required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return DraggableChild(foodItem: foodItem);
  }
}

class DraggableChild extends StatelessWidget {
  const DraggableChild({Key key, @required this.foodItem}) : super(key: key);
  final FoodItem foodItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ItemContent(foodItem: foodItem),
    );
  }
}

class DraggableChildFeedback extends StatelessWidget {
  const DraggableChildFeedback({Key key, @required this.foodItem})
      : super(key: key);
  final FoodItem foodItem;

  @override
  Widget build(BuildContext context) {
    final ColorBloc colorBloc = BlocProvider.getBloc<ColorBloc>();
    return Opacity(
      opacity: .7,
      child: Material(
        child: StreamBuilder(
            stream: colorBloc.colorStream,
            builder: (context, snapshot) {
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                child: ItemContent(foodItem: foodItem),
                decoration: BoxDecoration(
                    color:
                        snapshot.data != null ? snapshot.data : Colors.white),
              );
            }),
      ),
    );
  }
}

class ItemContent extends StatefulWidget {
  final FoodItem foodItem;

  ItemContent({@required this.foodItem});

  @override
  _ItemContentState createState() => _ItemContentState();
}

class _ItemContentState extends State<ItemContent> {
  final CartListBloc listBloc = BlocProvider.getBloc<CartListBloc>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(10),
              shadowColor: Colors.black,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.foodItem.foodItemImage,
                  fit: BoxFit.fill,
                  height: 45,
                  width: 60,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                    children: [
                      TextSpan(
                        text: widget.foodItem.quantity.toString(),
                      ),
                      TextSpan(text: ' x '),
                      TextSpan(
                          text: widget.foodItem.foodItemName,
                          style: TextStyle(
                              fontFamily: 'HindGuntur',
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 25,
                          height: 25,
                          decoration: new BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                              icon: Icon(
                                Icons.remove,
                                size: 10,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                listBloc.removeFromList(widget.foodItem);
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: Text(
                            widget.foodItem.quantity.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: 25,
                          height: 25,
                          decoration: new BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 10,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                listBloc.addToList(widget.foodItem);
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  color: Colors.black,
                )
              ],
            ),
            Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(5),
              shadowColor: Colors.black.withOpacity(.3),
              child: Text(
                "\R${widget.foodItem.quantity * widget.foodItem.foodItemPrice}",
                style: TextStyle(
                    fontWeight: FontWeight.w300, color: Colors.grey[700]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(5),
          child: GestureDetector(
            child: Icon(
              CupertinoIcons.back,
              size: 30,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        //DragTargetWidget(),
      ],
    );
  }
}

//class DragTargetWidget extends StatefulWidget {
//  @override
//  _DragTargetWidgetState createState() => _DragTargetWidgetState();
//}
//
//class _DragTargetWidgetState extends State<DragTargetWidget> {
//  final CartListBloc listBloc = BlocProvider.getBloc<CartListBloc>();
//  final ColorBloc colorBloc = BlocProvider.getBloc<ColorBloc>();
//
//  @override
//  Widget build(BuildContext context) {
//    return DragTarget<FoodItem>(
//      onWillAccept: (FoodItem foodItem) {
//        colorBloc.setColor(Colors.red);
//        return true;
//      },
////      onLeave: (FoodItem foodItem) {
////        colorBloc.setColor(Colors.white);
////      },
//      onAccept: (FoodItem foodItem) {
//        listBloc.removeFromList(foodItem);
//        colorBloc.setColor(Colors.white);
//      },
//      builder: (context, incoming, rejected) {
//        return Padding(
//          padding: EdgeInsets.all(5),
//          child: Icon(
//            CupertinoIcons.delete,
//            size: 35,
//          ),
//        );
//      },
//    );
//  }
//}
