import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/screens/authenticate.dart';
import 'package:vilmod/screens/home_page.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authenticate();
    } else {
      return MyHomePage();
    }
  }
}
