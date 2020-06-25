import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  Logo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Hero(
      tag: 'logo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 7.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          //foregroundColor: Colors.white,
          radius: 50.0,
          child: Image.asset(
            'assets/images/logo1.png',
            fit: BoxFit.cover,
//            width: 40.0,
//            height: 40.0,
          ),
        ),
      ),
    );
  }
}

class Logo2 extends StatelessWidget {
  Logo2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Hero(
      tag: 'logo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 7.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          //foregroundColor: Colors.white,
          radius: 30.0,
          child: Image.asset(
            'assets/images/logo1.png',
            width: 40.0,
          ),
        ),
      ),
    );
  }
}
