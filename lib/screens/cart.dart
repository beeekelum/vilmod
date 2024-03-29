import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vilmod/bloc/cartlist_bloc.dart';
import 'package:vilmod/bloc/list_style_color_bloc.dart';
import 'package:vilmod/components/logo.dart';
import 'package:vilmod/models/foodItem.dart';
import 'package:vilmod/models/notification.dart';
import 'package:vilmod/models/orders.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/screens/notifications.dart';
import 'package:vilmod/screens/test_payment.dart';
import 'package:vilmod/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart';
import 'package:vilmod/services/notification_service.dart';
import 'package:vilmod/services/order_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vilmod/utils/routes.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vilmod/widgets/styles.dart';
import 'package:flushbar/flushbar.dart';

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
                'Cart',
              ),
              actions: <Widget>[_shoppingCartBadge(foodItems.length)],
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
      position: BadgePosition.topRight(top: 0, right: 0),
      badgeColor: Colors.green,
      padding: EdgeInsets.all(8),
      elevation: 5,
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
  final NotificationService notificationService = NotificationService();
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

    await flutterLocalNotificationsPlugin.show(
        0,
        'Vilmod Restaurant',
        'Thank you new order created. Pay for your order.',
        platformChannelSpecifics,
        payload: 'test payload');
  }

  @override
  void initState() {
    //getInfo();
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

//    var orderNumber;
//
//    Firestore.instance
//          .collection('ordersIncrementNumber')
//          .document('COh9EvxuqkQq3MHjnIQM')
//          .updateData({"orderNumber": FieldValue.increment(1)});
//
//    Firestore.instance.collection("ordersIncrementNumber").document('COh9EvxuqkQq3MHjnIQM').get().then((value){
//      print(value.data['orderNumber']);
//      orderNumber = value.data['orderNumber'];
//    });

    var orderNumber = Random().nextInt(900000) + 100000;
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    String _orderType;
    String _userDeliveryLocation = '';

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
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text(
                            'Confirm Order',
                          ),
                          elevation: 10,
                        ),
                        body: SizedBox.expand(
                          // makes widget fullscreen
                          child: FormBuilder(
                            key: _fbKey,
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 5,
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Container(
                                      // height: MediaQuery.of(context).size.height,
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          colorFilter: new ColorFilter.mode(
                                              Colors.white.withOpacity(0.02),
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
                                            Logo(),
                                            _buildItem('Full Name:',
                                                '${user.firstName + ' ' + user.lastName}'),
                                            Divider(),
                                            _buildItem(
                                                'Email:', user.emailAddress),
                                            Divider(),
                                            _buildItem('Phone Number:',
                                                user.phoneNumber),
                                            Divider(),
                                            _buildItem(
                                                'Items Ordered:',
                                                widget.foodItems.length
                                                    .toString()),
                                            Divider(),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: widget.foodItems
                                                  .map((item) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
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
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    '${item.quantity.toString()} X '),
                                                                Container(
                                                                  width: 200,
                                                                  child: Text(
                                                                    item.foodItemName,
                                                                    style:
                                                                        TextStyle(
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
//
                                                          ],
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    '\R${returnTotalAmount(widget.foodItems)}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 25),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            FormBuilderRadio(
                                              decoration:
                                                  textFormFieldDecoration
                                                      .copyWith(
                                                          labelText:
                                                              "Order Type"),
                                              attribute: "order_type",
                                              validators: [
                                                FormBuilderValidators.required()
                                              ],
                                              options: [
                                                "Pick up",
                                                "Delivery",
                                              ]
                                                  .map((lang) =>
                                                      FormBuilderFieldOption(
                                                          value: lang))
                                                  .toList(growable: false),
                                              onChanged: (value) {
                                                setState(() {
                                                  _orderType = value;
                                                });
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            _orderType == "Delivery"
                                                ? FormBuilderTextField(
                                                    attribute:
                                                        'delivery_address',
                                                    decoration: textFormFieldDecoration
                                                        .copyWith(
                                                            labelText:
                                                                "Delivery address",
                                                            hintText:
                                                                "Enter the delivery address",
                                                            prefixIcon: Icon(
                                                              Icons.location_on,
                                                              color: Colors
                                                                  .red[900],
                                                            )),
                                                    onChanged: (value) {
                                                      _userDeliveryLocation =
                                                          value;
                                                    },
                                                    validators: [
                                                      FormBuilderValidators
                                                          .required(),
                                                      FormBuilderValidators
                                                          .minLength(5,
                                                              allowEmpty: true),
                                                    ],
                                                    keyboardType:
                                                        TextInputType.text,
                                                  )
                                                : Container(),
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
                                          List<FoodItem> foodItems =
                                              snapshot.data;
                                          return Column(
                                            children: [
                                              RaisedButton(
                                                color: Colors.red[900],
                                                shape:
                                                new RoundedRectangleBorder(
                                                    borderRadius:
                                                    new BorderRadius
                                                        .circular(
                                                        30.0)),
                                                elevation: 5,
                                                child: Text(
                                                  "Pay Now Online",
                                                  style: TextStyle(fontSize: 25),
                                                ),
                                                textColor: Colors.white,
                                                onPressed: () async {
                                                  if (_fbKey.currentState
                                                      .saveAndValidate()) {
                                                    List<String> order =
                                                        new List<String>();
                                                    int totalAmount = 0;

                                                    for (int i = 0;
                                                        i < widget.foodItems.length;
                                                        i++) {
                                                      int itemTotal = widget
                                                              .foodItems[i]
                                                              .quantity *
                                                          widget.foodItems[i]
                                                              .foodItemPrice;
                                                      totalAmount = totalAmount +
                                                          widget.foodItems[i]
                                                                  .quantity *
                                                              widget.foodItems[i]
                                                                  .foodItemPrice;
                                                      ;
                                                      order.add(widget
                                                              .foodItems[i].quantity
                                                              .toString() +
                                                          " x " +
                                                          widget.foodItems[i]
                                                              .foodItemName +
                                                          " = R" +
                                                          itemTotal.toString());
                                                    }
                                                    Order newOrder = Order(
                                                        orderNumber:
                                                            'VR${orderNumber.toString()}',
                                                        userUid: user.uid,
                                                        userName:
                                                            '${user.firstName + ' ' + user.lastName}',
                                                        userPhoneNumber:
                                                            user.phoneNumber,
                                                        userAddress:
                                                            _userDeliveryLocation,
                                                        userEmail:
                                                            user.emailAddress,
                                                        dateOrderCreated:
                                                            DateTime.now(),
                                                        orderItems: order,
                                                        orderTotalAmount:
                                                            'R${totalAmount.toString()}',
                                                        orderStatus: 'New',
                                                        flag: 'New Order',
                                                        tAmount: totalAmount,
                                                        paymentStatus: 'Not Paid',
                                                        orderType: _orderType,
                                                        platform: 'MOBILE');
                                                    orderService.addOrder(newOrder);
                                                    //_showNotification();

                                                    //store notification in the database--------------------
                                                    OrderNotification
                                                        newNotification =
                                                        OrderNotification(
                                                      //notificationId: '',
                                                      userUid: user.uid,
                                                      title: 'New order',
                                                      body:
                                                          'Thank you new order created.',
                                                      isRead: false,
                                                      orderNumber:
                                                          'VR${orderNumber.toString()}',
                                                      dateCreated: DateTime.now(),
                                                    );
                                                    notificationService
                                                        .addNotification(
                                                            newNotification);
                                                    Navigator.of(context).push(
                                                      FadePageRoute(
                                                        builder: (c) {
                                                          return ProcessOrderPayment(
                                                            orderNumber:
                                                                'VR${orderNumber.toString()}',
                                                            amount: totalAmount,
                                                          );
                                                        },
                                                        settings:
                                                            new RouteSettings(),
                                                      ),
                                                    );
                                                  } else {
                                                    print(
                                                        _fbKey.currentState.value);
                                                    print('validation failed');
                                                  }
                                                },
                                              ),

                                              RaisedButton(onPressed: () async{
                                                if (_fbKey.currentState
                                                    .saveAndValidate()) {
                                                  List<String> order =
                                                  new List<String>();
                                                  int totalAmount = 0;

                                                  for (int i = 0;
                                                  i < widget.foodItems.length;
                                                  i++) {
                                                    int itemTotal = widget
                                                        .foodItems[i]
                                                        .quantity *
                                                        widget.foodItems[i]
                                                            .foodItemPrice;
                                                    totalAmount = totalAmount +
                                                        widget.foodItems[i]
                                                            .quantity *
                                                            widget.foodItems[i]
                                                                .foodItemPrice;
                                                    ;
                                                    order.add(widget
                                                        .foodItems[i].quantity
                                                        .toString() +
                                                        " x " +
                                                        widget.foodItems[i]
                                                            .foodItemName +
                                                        " = R" +
                                                        itemTotal.toString());
                                                  }
                                                  Order newOrder = Order(
                                                      orderNumber:
                                                      'VR${orderNumber.toString()}',
                                                      userUid: user.uid,
                                                      userName:
                                                      '${user.firstName + ' ' + user.lastName}',
                                                      userPhoneNumber:
                                                      user.phoneNumber,
                                                      userAddress:
                                                      _userDeliveryLocation,
                                                      userEmail:
                                                      user.emailAddress,
                                                      dateOrderCreated:
                                                      DateTime.now(),
                                                      orderItems: order,
                                                      orderTotalAmount:
                                                      'R${totalAmount.toString()}',
                                                      orderStatus: 'New',
                                                      flag: 'New Order',
                                                      tAmount: totalAmount,
                                                      paymentStatus: 'Not Paid',
                                                      orderType: _orderType,
                                                      platform: 'MOBILE');
                                                  orderService.addOrder(newOrder);
                                                  //_showNotification();

                                                  //store notification in the database--------------------
                                                  OrderNotification
                                                  newNotification =
                                                  OrderNotification(
                                                    //notificationId: '',
                                                    userUid: user.uid,
                                                    title: 'New order',
                                                    body:
                                                    'Thank you new order created.',
                                                    isRead: false,
                                                    orderNumber:
                                                    'VR${orderNumber.toString()}',
                                                    dateCreated: DateTime.now(),
                                                  );
                                                  notificationService
                                                      .addNotification(
                                                      newNotification).then((value) => Flushbar(
                                                      //aroundPadding: EdgeInsets.all(10),
                                                      borderRadius: 10,
                                                      backgroundGradient: LinearGradient(
                                                        colors: [Colors.green.shade600, Colors.green.shade500],
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
                                                      duration: Duration(milliseconds: 4000),
                                                      flushbarPosition: FlushbarPosition.TOP,
                                                      icon: Icon(
                                                        Icons.add_shopping_cart,
                                                        color: Colors.white,
                                                      ),
                                                      shouldIconPulse: true,
                                                      title: 'New Order',
                                                      message: 'New Order created payment to be done at the restaurant.',
                                                    )..show(context).then((value) => Navigator.of(context)
                                                      .pushNamedAndRemoveUntil('/home_page',
                                                          (Route<dynamic> route) => false)));
                                                } else {
                                                  print(
                                                      _fbKey.currentState.value);
                                                  print('validation failed');
                                                }
                                              },  color: Colors.red[900],
                                                elevation: 10,
                                                shape:
                                                new RoundedRectangleBorder(
                                                    borderRadius:
                                                    new BorderRadius
                                                        .circular(
                                                        30.0)),
                                                textColor: Colors.white,
                                                child: Text(
                                                  "Pay at the Restaurant",
                                                  style: TextStyle(fontSize: 25),
                                                ),)
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 50, left: 50),
              height: 50,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xfffeb324),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Checkout',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
          ),
          Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(5),
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
      elevation: 10,
      borderRadius: BorderRadius.circular(5),
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
//                  fontWeight: FontWeight.bold,
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
                              fontFamily: 'Poppins',
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
