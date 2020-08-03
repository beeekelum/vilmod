import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:vilmod/screens/wrapper.dart';

class VMSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 5,
        navigateAfterSeconds: new Wrapper(),
        image: Image.asset(
          'assets/images/logo1.png',
        ),
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
       // onClick: () => print(""),
        loaderColor: Colors.red[900],
        loadingText: Text(
          'Loading ...',
          style: TextStyle(fontSize: 18, color: Colors.red[900]),
        ),
        gradientBackground: LinearGradient(
          colors: [
            Colors.white,
            Colors.white,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ));
  }
}
