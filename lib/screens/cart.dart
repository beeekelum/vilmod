import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vilmod/bloc/cartlist_bloc.dart';
import 'package:vilmod/bloc/list_style_color_bloc.dart';
import 'package:vilmod/models/foodItem.dart';

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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              //centerTitle: true,
              actions: <Widget>[
                //DragTargetWidget(),
              ],
              elevation: 0,
            ),
            body: SafeArea(
              child: Container(
                child: CartBody(foodItems),
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
}

class BottomBar extends StatelessWidget {
  final List<FoodItem> foodItems;

  BottomBar(this.foodItems);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 35, bottom: 35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          totalAmount(foodItems),
          Container(
//            margin: EdgeInsets.only(right: 10),
//            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(
              height: 1,
              color: Colors.grey[700],
            ),
          ),
          //persons(),
          nextButtonBar(context),
        ],
      ),
    );
  }

  GestureDetector nextButtonBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Confirm Order',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Divider(),
                  new Row(
                    children: <Widget>[
                      new Expanded(
                        child: CircleAvatar(
                          child: Icon(
                            Icons.done,
                            size: 40,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.green,
                          radius: 30,
                        ),
                      )
                    ],
                  ),
                  //Container(child: CartBody(foodItems)),
                  Divider(),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.red,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.green,
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
            'Total amount:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Text(
            '\R${returnTotalAmount(foodItems)}',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
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
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(10),
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
                'My',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              Text(
                'Order',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
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
    return Draggable(
      data: foodItem,
      maxSimultaneousDrags: 1,
      child: DraggableChild(foodItem: foodItem),
      feedback: DraggableChildFeedback(foodItem: foodItem),
      childWhenDragging: foodItem.quantity > 1
          ? DraggableChild(
              foodItem: foodItem,
            )
          : Container(),
    );
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
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                widget.foodItem.foodItemImage,
                fit: BoxFit.fill,
                height: 50,
                width: 60,
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
                          style: TextStyle(fontFamily: 'HindGuntur', fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.remove,
                            ),
                            onPressed: () {
                              listBloc.removeFromList(widget.foodItem);
                            }),
                        Text(widget.foodItem.quantity.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                        IconButton(
                            icon: Icon(
                              Icons.add,
                            ),
                            onPressed: () {
                              listBloc.addToList(widget.foodItem);
                            }),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            Text(
              "\R${widget.foodItem.quantity * widget.foodItem.foodItemPrice}",
              style:
                  TextStyle(fontWeight: FontWeight.w300, color: Colors.grey[900]),
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
