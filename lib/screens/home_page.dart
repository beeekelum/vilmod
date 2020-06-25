import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/animations/FadeAnimation.dart';
import 'package:vilmod/bloc/cartlist_bloc.dart';
import 'package:vilmod/components/logo.dart';
import 'package:vilmod/models/foodItem.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/screens/cart.dart';
import 'package:vilmod/screens/mobile_profile.dart';
import 'package:vilmod/screens/my_orders.dart';
import 'package:vilmod/services/auth.dart';
import 'package:vilmod/services/database.dart';
import 'package:vilmod/services/food_menu_service.dart';
import 'package:vilmod/utils/SizeConfig.dart';
import 'package:vilmod/widgets/drawer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var contents = "Menu";
  var _curIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();
  bool isActive = false;
  final AuthService _auth = AuthService();
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }
    _subscribeToTopic();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // final snackbar = SnackBar(
        //   content: Text(message['notification']['title']),
        //   action: SnackBarAction(
        //     label: 'Go',
        //     onPressed: () => null,
        //   ),
        // );

        // Scaffold.of(context).showSnackBar(snackbar);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new MyOrders()));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new MyOrders()));
      },
    );
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vilmod Restaurant',
        ),
        //centerTitle: true,
        actions: <Widget>[
          StreamBuilder(
            stream: bloc.listStream,
            builder: (context, snapshot) {
              List<FoodItem> foodItems = snapshot.data;
              int length = foodItems != null ? foodItems.length : 0;
              return buildGestureDetector(length, context, foodItems);
            },
          ),
          IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt),
              onPressed: () async {
                await _auth.signOut();
              })
        ],
        //elevation: 0,
      ),
      key: _scaffoldKey,
      //drawer: AppDrawer(),
      //body: _getBody(_curIndex),
      //bottomNavigationBar: _userItemIconOnly(),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 45.0,
        items: <Widget>[
          Column(
            children: <Widget>[
              Icon(Icons.restaurant, size: 20),
              Text('Menu')
            ],
          ),
          Column(
            children: <Widget>[
              Icon(Icons.receipt, size: 20),
              Text('Orders')
            ],
          ),
          Column(
            children: <Widget>[
              Icon(Icons.person, size: 20),
              Text('Profile')
            ],
          ),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.red[900],
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 700),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
        body: _getBody(_page),
      drawer: AppDrawerVilMod(),
    );

  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    // Get the current user
    FirebaseUser user = await _auth.currentUser();
    //print("Current user is : ${user.uid}");

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = _db
          .collection('users')
          .document(user.uid);

      await tokens.updateData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }
  // Subscribe the user to a topic
  _subscribeToTopic() async {
    _fcm.subscribeToTopic('vilmod');
  }
  GestureDetector buildGestureDetector(
      int length, BuildContext context, List<FoodItem> foodItems) {
    return GestureDetector(
      onTap: () {
        if (length > 0) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Cart()));
        } else {
          return;
        }
      },
      child: InkResponse(
        child: new Container(
          margin: EdgeInsets.only(right: 20),
          width: 25,
          height: 25,
          decoration: new BoxDecoration(
            color: Colors.yellow[800],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              length.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userItemIconOnly() => BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.restaurant,
              size: 20,
              color: Colors.black,
            ),
            title: Text(
              "Menu",
              style: TextStyle(
                  fontSize: 15,
                  color: _curIndex == 0 ? Colors.red[900] : Colors.black),
            ),
            activeIcon: Icon(
              Icons.restaurant,
              size: 20,
              color: Colors.red[900],
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt,
              size: 20,
              color: Colors.black,
            ),
            title: Text(
              "My Orders",
              style: TextStyle(
                  fontSize: 15,
                  color: _curIndex == 1 ? Colors.red[900] : Colors.black),
            ),
            activeIcon: Icon(
              Icons.receipt,
              size: 20,
              color: Colors.red[900],
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 20,
              color: Colors.black,
            ),
            title: Text(
              "Profile",
              style: TextStyle(
                  fontSize: 15,
                  color: _curIndex == 3 ? Colors.red[900] : Colors.black),
            ),
            activeIcon: Icon(
              Icons.person,
              size: 20,
              color: Colors.red[900],
            ),
          ),
        ],
        currentIndex: _curIndex,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.red[900],
        onTap: (index) {
          setState(
            () {
              _curIndex = index;
            },
          );
        },
      );

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return Explore();
      case 1:
        return MyOrders();
      case 2:
        return MobileProfile();
    }
    return Center(
      child: Text("Not yet available"),
    );
  }
}

class ItemContainer extends StatelessWidget {
  ItemContainer({
    @required this.foodItem,
  });

  final FoodItem foodItem;
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  addToCart(FoodItem foodItem) {
    bloc.addToList(foodItem);
  }

  removeFromList(FoodItem foodItem) {
    bloc.removeFromList(foodItem);
  }

  void showFloatingFlushbar(BuildContext context, String foodItem) {
    Flushbar(
      //aroundPadding: EdgeInsets.all(10),
      borderRadius: 10,
      backgroundGradient: LinearGradient(
        colors: [Colors.red.shade900, Colors.red.shade600],
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
      duration: Duration(milliseconds: 1500),
      flushbarPosition: FlushbarPosition.BOTTOM,
      icon: Icon(
        Icons.add_shopping_cart,
        color: Colors.white,
      ),
      shouldIconPulse: true,
      title: '$foodItem',
      message: '$foodItem added to cart',
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        addToCart(foodItem);
        showFloatingFlushbar(context, foodItem.foodItemName);
      },
      child: Items(
        foodImage: foodItem.foodItemImage,
        foodName: foodItem.foodItemName,
        foodPrice: foodItem.foodItemPrice,
        foodIngredients: foodItem.foodItemDescription,
        foodCategory: foodItem.foodItemCategory,
        isADeal: foodItem.isDeal,
        foodItemID: foodItem.id,
        leftAligned: (foodItem.id % 2) == 0 ? true : false,
      ),
    );
  }
}

class ItemContainerDeals extends StatelessWidget {
  ItemContainerDeals({
    @required this.foodItem,
  });

  final FoodItem foodItem;
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  addToCart(FoodItem foodItem) {
    bloc.addToList(foodItem);
  }

  removeFromList(FoodItem foodItem) {
    bloc.removeFromList(foodItem);
  }

  void showFloatingFlushbar(BuildContext context, String foodItem) {
    Flushbar(
      borderRadius: 10,
      backgroundGradient: LinearGradient(
        colors: [Colors.green.shade800, Colors.green.shade600],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      duration: Duration(milliseconds: 1000),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(
        Icons.add_shopping_cart,
        color: Colors.white,
      ),
      shouldIconPulse: true,
      title: '$foodItem',
      message: '$foodItem added to cart',
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        addToCart(foodItem);
        showFloatingFlushbar(context, foodItem.foodItemName);
      },
      child: ItemsDeals(
        foodImage: foodItem.foodItemImage,
        foodName: foodItem.foodItemName,
        foodPrice: foodItem.foodItemPrice,
        foodIngredients: foodItem.foodItemDescription,
        foodCategory: foodItem.foodItemCategory,
        isADeal: foodItem.isDeal,
        foodItemID: foodItem.id,
        leftAligned: (foodItem.id % 2) == 0 ? true : false,
      ),
    );
  }
}

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final auth = FirebaseAuth.instance;
  final db = FoodMenuServices();
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  addToCart(FoodItem foodItem) {
    bloc.addToList(foodItem);
  }

  removeFromList(FoodItem foodItem) {
    bloc.removeFromList(foodItem);
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
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
                begin: Alignment.topCenter,
                end: Alignment.bottomLeft,
                colors: [
                  //Colors.red[900].withOpacity(.7),
                  Colors.black.withOpacity(.7),
                  Colors.black.withOpacity(.7),
                  Colors.black.withOpacity(.7),
                ],
              ),
            ),
            //   ),
          ),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              child: Column(
                children: <Widget>[
                  FirstHalf(),
                  FadeAnimation(1.8, _buildCategory()),
                  SizedBox(height: 5),
                  FadeAnimation(2.0, _buildDeals('Deal')),
                  new Container(
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: new TabBar(
                      isScrollable: true,
                      indicatorWeight: 1,
                      indicatorColor: Colors.red[900],
                      controller: _tabController,
                      tabs: [
                        new Tab(
                          child: FadeAnimation(
                              1,
                              makeCategory(
                                  isActive: false, title: 'Breakfast')),
                        ),
                        new Tab(
                          child: FadeAnimation(1.3,
                              makeCategory(isActive: false, title: 'Lunch')),
                        ),
                        new Tab(
                          child: FadeAnimation(
                              1.4,
                              makeCategory(
                                  isActive: false, title: 'Salads & Platters')),
                        ),
                        new Tab(
                          child: FadeAnimation(
                              1.5,
                              makeCategory(
                                  isActive: false, title: 'Hot Drinks')),
                        ),
                        new Tab(
                          child: FadeAnimation(
                              1.6,
                              makeCategory(
                                  isActive: false, title: 'Soft Drinks')),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 5),
                    child: new Container(
                      height: MediaQuery.of(context).size.height / .4,
                      //height: MediaQuery.of(context).size.height,
                      child: new TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'Breakfast includes (Sandwiches & croissants, Freshly baked)',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                    fontFamily: 'SpectralSC'),
                                textAlign: TextAlign.center,
                              ),
                              _buildSpaceWidget(2),
                              Expanded(child: _buildFoodMenuListView('Breakfast')),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'All Meals to be served with a portion of starch (Pap, Rice, Samp, Dumpling, Salad or Chips) Together with 2 vegies',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                    fontFamily: 'SpectralSC'),
                                textAlign: TextAlign.center,
                              ),
                              _buildSpaceWidget(2),
                              Expanded(child: _buildFoodMenuListView('Lunch')),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Vegetable, Salads and Platters',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                    fontFamily: 'SpectralSC'),
                                textAlign: TextAlign.center,
                              ),
                              _buildSpaceWidget(2),
                              Expanded(child: _buildFoodMenuListView('Salads')),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Hot Beverages',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                    fontFamily: 'SpectralSC'),
                                textAlign: TextAlign.center,
                              ),
                              _buildSpaceWidget(2),
                              Expanded(child: _buildFoodMenuListView('Hot Drinks')),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Cold Beverages',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                    fontFamily: 'SpectralSC'),
                                textAlign: TextAlign.center,
                              ),
                              _buildSpaceWidget(2),
                              Expanded(child: _buildFoodMenuListView('Soft Drinks')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeals(String menuType) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.local_offer, color: Colors.yellow,),
              Text(
                'Special Offers',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Container(
          child: SizedBox(
            height: 130,
            child: StreamBuilder<List<FoodItem>>(
              stream: db.streamFoodItems(menuType),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Text(
                    "No Menu Items available yet",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  );
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.toList().length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ItemContainerDeals(
                          foodItem: snapshot.data.toList()[index]),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategory() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.restaurant, color: Colors.green,),
              Text(
                'Categories',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: StreamBuilder(
              stream: Firestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Text(
                    "No Menu Items available yet",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  );
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  // shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot category = snapshot.data.documents[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        child: Container(
                          width: 120,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 30,
                                child: Center(
                                  child: CachedNetworkImage(
                                    imageUrl: category['image'],
                                    fit: BoxFit.fill,
                                    fadeInCurve: Curves.easeIn,
                                    fadeInDuration: Duration(seconds: 2),
                                    fadeOutCurve: Curves.easeOut,
                                    fadeOutDuration: Duration(seconds: 2),
                                  ),
                                ),
                              ),
                              Text(
                                category['name'],
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
        ),
      ],
    );
  }

  Widget _buildSpaceWidget(int height) {
    return SizedBox(
      height: height * SizeConfig.heightMultiplier,
    );
  }

  Widget _buildFoodMenuListView(String menuType) {
    return Container(
      child: StreamBuilder<List<FoodItem>>(
        stream: db.streamFoodItems(menuType),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Text(
              "No Menu Items available yet",
              style: TextStyle(color: Colors.white, fontSize: 20),
            );
          return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              physics: BouncingScrollPhysics(),

              itemCount: snapshot.data.toList().length,
              itemBuilder: (BuildContext context, int index) {
                return ItemContainer(foodItem: snapshot.data.toList()[index]);
              });
//          return ListView.builder(
//            physics: NeverScrollableScrollPhysics(),
//            shrinkWrap: true,
//            scrollDirection: Axis.vertical,
//            itemCount: snapshot.data.toList().length,
//            itemBuilder: (BuildContext context, int index) {
//              return ItemContainer(foodItem: snapshot.data.toList()[index]);
//            },
//          );
        },
      ),
    );
  }

  Widget makeCategory({isActive, title}) {
    return AspectRatio(
      aspectRatio: isActive ? 3 : 3 / 1,
      child: Container(
        margin: EdgeInsets.only(right: 10),
        child: Align(
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class Items extends StatelessWidget {
  Items({
    @required this.foodImage,
    @required this.foodName,
    @required this.foodPrice,
    @required this.foodIngredients,
    @required this.foodCategory,
    @required this.isADeal,
    @required this.foodItemID,
    @required this.leftAligned,
  });

  final String foodImage;
  final String foodName;
  final int foodPrice;
  final String foodIngredients;
  final String foodCategory;
  final String isADeal;
  final int foodItemID;
  final bool leftAligned;

  @override
  Widget build(BuildContext context) {
    double containerPadding = 45;

    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 1),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image:
                      DecorationImage(
                        image: CachedNetworkImageProvider(foodImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            stops: [.2, .8],
                            colors: [
                              Colors.black.withOpacity(.8),
                              Colors.black.withOpacity(.2),
                            ],
                          ),
                        ),
                        child:  Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        Icons.add_shopping_cart,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "R" + foodPrice.toStringAsFixed(2),
                                          //"\R $foodPrice",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          foodName,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'SpectralSC',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        RatingBar(
                                          initialRating: 3,
                                          minRating: 1,
                                          itemSize: 18,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            print(rating);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ),
                  ),
                ],
              ),
            ))
      ],
    );
  }
}

class ItemsDeals extends StatelessWidget {
  ItemsDeals({
    @required this.foodImage,
    @required this.foodName,
    @required this.foodPrice,
    @required this.foodIngredients,
    @required this.foodCategory,
    @required this.isADeal,
    @required this.foodItemID,
    @required this.leftAligned,
  });

  final String foodImage;
  final String foodName;
  final int foodPrice;
  final String foodIngredients;
  final String foodCategory;
  final String isADeal;
  final int foodItemID;
  final bool leftAligned;

  @override
  Widget build(BuildContext context) {
    double containerPadding = 45;

    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height:120,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(foodImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            stops: [.1, .8],
                            colors: [
                              Colors.black.withOpacity(.8),
                              Colors.black.withOpacity(.3),
                            ],
                          ),
                        ),
                        child: isADeal == "Deal"
                            ? Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        Icons.local_offer,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "R" + foodPrice.toStringAsFixed(2),
                                          //"\R $foodPrice",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          foodName,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : Container()),
                  ),
                  isADeal != "Deal"
                      ? SizedBox(
                          height: 10,
                        )
                      : Container(),
                  isADeal != "Deal"
                      ? Container(
                          padding: EdgeInsets.only(
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      foodIngredients,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'SpectralSC'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: containerPadding,
                              ),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
            ))
      ],
    );
  }
}

class FirstHalf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Column(
        children: <Widget>[
          FadeAnimation(1, WelcomeUser()),
          FadeAnimation(1.3, title()),
          SizedBox(height: 5),
          FadeAnimation(1.6, searchBar(context)),
          // _buildCategory()
        ],
      ),
    );
  }

  Widget makeCategory({isActive, title}) {
    return AspectRatio(
      aspectRatio: isActive ? 3 : 3 / 1,
      child: Container(
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.yellow[800] : Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Align(
          child: Text(
            title,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[900],
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget searchBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white,
                ),
                color: Colors.white),
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: InputBorder.none,
//                contentPadding:
//                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                hintStyle: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Logo2(),
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'VilMod Menu',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  //fontFamily: 'Amita',
                  color: Colors.white),
            ),
            Text(
              'Order your food now',
              style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 16,
                  color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

class WelcomeUser extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  final ds = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return StreamBuilder<User>(
      stream: DatabaseService(uid: user?.uid).userData,
      builder: (context, snapshot) {
        var user = snapshot.data;
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                'Hi ${user?.firstName}',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Amita',),
              ),
            ),
          ],
        );
      },
    );
  }
}
