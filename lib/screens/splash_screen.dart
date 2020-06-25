import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:vilmod/screens/wrapper.dart';

class VMSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: new Wrapper(),
      image: Image.asset(
        'assets/images/logo1.png',
      ),
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 130.0,
      onClick: () => print(""),
      loaderColor: Colors.red,
      loadingText: Text(
        'Loading ...',
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
      gradientBackground: LinearGradient(
        // Where the linear gradient begins and ends
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        // Add one stop for each color. Stops should increase from 0 to 1
        stops: [0.1, 0.5, 0.7, 0.9],
        colors: [
          Colors.white,
          Colors.white,
          Colors.white,
          Colors.white,
        ],
      ),
    );
  }
}
