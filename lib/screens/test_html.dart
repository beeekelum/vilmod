import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() => runApp(MyApp());

class ProcessOrderPayment extends StatefulWidget {
  @override
  _ProcessOrderPaymentState createState() => _ProcessOrderPaymentState();
}

class _ProcessOrderPaymentState extends State<ProcessOrderPayment> {
  InAppWebViewController webView;
  String url = "https://sandbox.payfast.co.za/eng/process";

  //String url = "https://www.payfast.co.za/eng/process";
  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Order Payment"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text("$url", overflow: TextOverflow.ellipsis),
            ),
            (progress != 1.0) ? LinearProgressIndicator(value: progress) : null,
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: InAppWebView(
//                  initialUrl: url,
                  initialHeaders: {},
                  //initialOptions: {},
                  onWebViewCreated: (InAppWebViewController controller) async {
                    webView = controller;
                    //  String output = "merchant_id=${Uri.encodeComponent("10013380")}&";
                    //  output += "merchant_key=${Uri.encodeComponent("chs8iasdjv0f9")}&";
                    String output =
                        "merchant_id=${Uri.encodeComponent("14004753")}&";
                    output +=
                        "merchant_key=${Uri.encodeComponent("rhlrhybjd6j2n")}&";
                    output +=
                        "return_url=${Uri.encodeComponent("http://www.mitreasureapp.com/payment_success")}&";
                    output +=
                        "cancel_url=${Uri.encodeComponent("http://www.mitreasureapp.com/payment_cancelled")}&";
                    // output += "notify_url=${Uri.encodeComponent("https://us-central1-mitreasure-dev.cloudfunctions.net/processPayment/")}&";
                    output +=
                        "notify_url=${Uri.encodeComponent("https://us-central1-mitreasureapp.cloudfunctions.net/processPayment/")}&";
                    output += "name_first=${Uri.encodeComponent('Blessing')}&";
                    output += "name_last=${Uri.encodeComponent('Chelinje')}&";
                    if (!('bchelinje@gmail.com' == null ||
                        'bchelinje@gmail.com'.isEmpty)) {
                      //  output += "email_address=" + Uri.encodeComponent("sbtu01@payfast.co.za") + "&";
                      output += "email_address=" +
                          Uri.encodeComponent('bchelinje@gmail.com') +
                          "&";
                    }
                    if (!('0817486443' == null || '0817486443'.isEmpty)) {
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
                        "m_payment_id=${Uri.encodeComponent('898913939')}&";
                    output +=
                        "amount=${Uri.encodeComponent(numberFormat(40, "0.00"))}&";
                    output +=
                        "item_name=${Uri.encodeComponent("Vilmod Order")}&";
                    output +=
                        "item_description=${Uri.encodeComponent("Order Details")}";

                    output =
                        output.replaceAll("%20", "+").replaceAll("@", "%40");

                    print("Output = " + output);

                    String signature = generateMd5(output);
                    print("Signature = " + signature);

                    output += "&signature=" + signature;

                    Uint8List uint8List =
                        new Uint8List.fromList((output).codeUnits);
                    print("Uint8List -> $uint8List");
                    await webView.postUrl(url: url, postData: uint8List);
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    print("started $url");
                    setState(() => this.url = url);
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100.0;
                    });
                  },
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Icon(Icons.refresh),
                  onPressed: () {
                    if (webView != null) {
                      webView.reload();
                    }
                  },
                ),
              ],
            ),
          ].where((Object o) => o != null).toList(),
        ),
      ),
    );
  }
}

String generateMd5(String data) {
  return crypto.md5.convert(utf8.encode(data)).toString();
}

String numberFormat(double value, String pattern) {
  NumberFormat df = new NumberFormat(pattern);
  return df.format(value);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: ProcessOrderPayment(),
      );
}
