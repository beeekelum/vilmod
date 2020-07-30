import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:vilmod/screens/wrapper.dart';

class VMSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 10,
      navigateAfterSeconds: new Wrapper(),
      image: Image.asset(
        'assets/images/logo1.png',
      ),
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 130.0,
      onClick: () => print(""),
      loaderColor: Colors.white,
      loadingText: Text(
        'Loading ...',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      gradientBackground:LinearGradient(
        colors: [Colors.white,Colors.red[900], Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
      )
    );
  }
}
