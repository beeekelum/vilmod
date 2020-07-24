import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vilmod/bloc/cartlist_bloc.dart';
import 'package:vilmod/models/foodItem.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

class ProcessOrderPayment extends StatefulWidget {
  ProcessOrderPayment({this.orderNumber, this.amount});

  final String orderNumber;
  final int amount;

  @override
  _ProcessOrderPaymentState createState() => _ProcessOrderPaymentState();
}

class _ProcessOrderPaymentState extends State<ProcessOrderPayment> {
  InAppWebViewController webView;
  //String url = "https://sandbox.payfast.co.za/eng/process";
  String url = "https://www.payfast.co.za/eng/process";
  double progress = 0.0;
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit VilMod app'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return StreamBuilder<User>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          var user = snapshot.data;
          return Scaffold(
            appBar: AppBar(
                elevation: 0,
                title: const Text("VilMod Order Payment"),
                centerTitle: true,
                automaticallyImplyLeading: false),
            body: Container(
              child: Column(
                children: <Widget>[
//                  Container(
//                    padding: EdgeInsets.all(2.0),
//                    child: Text(
//                      "$url",
//                      overflow: TextOverflow.ellipsis,
//                      maxLines: 1,
//                    ),
//                  ),
                  (progress != 1.0)
                      ? LinearProgressIndicator(value: progress)
                      : null,
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(0.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent)),
                      child: InAppWebView(
                        initialHeaders: {},
                        //initialOptions: {},
                        onWebViewCreated:
                            (InAppWebViewController controller) async {
                          webView = controller;
                          String output =
                              //"merchant_id=${Uri.encodeComponent("10013380")}&";
                              "merchant_id=${Uri.encodeComponent("14004753")}&";
                          output +=
                              //"merchant_key=${Uri.encodeComponent("chs8iasdjv0f9")}&";
                              "merchant_key=${Uri.encodeComponent("rhlrhybjd6j2n")}&";
                          output +=
                              "return_url=${Uri.encodeComponent("https://firebasestorage.googleapis.com/v0/b/vilmod-534db.appspot.com/o/success_page.html?alt=media&token=110a4933-3556-4496-ac78-7d5a1eafa487")}&";
                          output +=
                              "cancel_url=${Uri.encodeComponent("https://firebasestorage.googleapis.com/v0/b/vilmod-534db.appspot.com/o/cancelled_page.html?alt=media&token=91058d64-1092-469c-ad99-2e04f8f01709")}&";
                          output +=
                              "notify_url=${Uri.encodeComponent("https://us-central1-vilmod-a6f63.cloudfunctions.net/processPayment/")}&";
                          output +=
                              "name_first=${Uri.encodeComponent(user?.firstName.toString())}&";
                          output +=
                              "name_last=${Uri.encodeComponent(user?.lastName.toString())}&";
                          if (!(user?.emailAddress == null ||
                              user.emailAddress.isEmpty)) {
                            output += "email_address=" +
                                Uri.encodeComponent(
                                    user?.emailAddress.toString()) +
                                "&";
                          }
                          if (!('0817486443' == null ||
                              '0817486443'.isEmpty)) {
                            String cellNumber =
                                '0817486443'.replaceFirst("+", "00").trim();
                            if (cellNumber.startsWith("0027")) {
                              output += "cell_number=" +
                                  Uri.encodeComponent(
                                      cellNumber.replaceFirst("0027", "0")) +
                                  "&";
                            }
                          }
                          output +=
                              "m_payment_id=${Uri.encodeComponent(widget.orderNumber)}&";
                          output +=
                              "amount=${Uri.encodeComponent(numberFormat(widget.amount.toDouble(), "0.00"))}&";
                          output +=
                              "item_name=${Uri.encodeComponent("Vilmod Order")}&";
                          output +=
                              "item_description=${Uri.encodeComponent("Order Details")}";

                          output = output
                              .replaceAll("%20", "+")
                              .replaceAll("@", "%40");
                          String signature = generateMd5(output);
                          output += "&signature=" + signature;

                          Uint8List uint8List =
                              new Uint8List.fromList((output).codeUnits);
                          await webView.postUrl(
                              url: url, postData: uint8List);
                        },
                        onLoadStart:
                            (InAppWebViewController controller, String url) {
                          setState(() => this.url = url);
                        },
                        onProgressChanged: (InAppWebViewController controller,
                            int progress) {
                          setState(() {
                            this.progress = progress / 100.0;
                          });
                        },
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: bloc.listStream,
                    builder: (context, snapshot) {
                      List<FoodItem> foodItems = snapshot.data;
                      return ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              RaisedButton.icon(
                                label: Text('Home'),
                                icon: Icon(Icons.home),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                color: Colors.red[900],
                                onPressed: () {
                                  foodItems.clear();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/home_page',
                                      (Route<dynamic> route) => false);
                                },
                              ),
                              RaisedButton.icon(
                                label: Text('Reload'),
                                icon: Icon(Icons.refresh),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                color: Colors.red[900],
                                onPressed: () {
                                  if (webView != null) {
                                    webView.reload();
                                  }
                                },
                              ),
                              RaisedButton.icon(
                                label: Text('Exit app'),
                                icon: Icon(Icons.cancel),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                color: Colors.red[900],
                                onPressed: () {
                                  //SystemNavigator.pop();
                                  _onWillPop();
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  ),
                ].where((Object o) => o != null).toList(),
              ),
            ),
          );
        });
  }
}

String generateMd5(String data) {
  return crypto.md5.convert(utf8.encode(data)).toString();
}

String numberFormat(double value, String pattern) {
  NumberFormat df = new NumberFormat(pattern);
  return df.format(value);
}
