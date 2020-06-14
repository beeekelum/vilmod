import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vilmod/widgets/styles.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PasswordReset extends StatefulWidget {
  PasswordReset({Key key}) : super(key: key);

  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  //  _formKey and _autoValidate
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _emailAddress;

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 50.0,
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo1.png',
              fit: BoxFit.cover,
//              width: 100.0,
//              height: 100.0,
            ),
          )),
    );
    return SafeArea(
      child: Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
            'Reset Password',
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
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
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.5),
                  ],
                  //begin: Alignment.bottomLeft,
                  begin: Alignment.topCenter,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  margin: new EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      logo,
                      new Container(
                        margin: new EdgeInsets.all(15.0),
                        child: new Form(
                          key: _formKey,
                          autovalidate: _autoValidate,
                          child: formUI(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget formUI() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Container(margin: EdgeInsets.only(top: 24.0)),
            //Logo(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Forgot your Password?",
                    style: TextStyle(fontSize: 22.0, color: Colors.white,fontWeight: FontWeight.w600,),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
              child: Text(
                "Enter registered Email Address to send you the password reset instructions.",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0),
              child: TextFormField(
                decoration: textFormFieldDecoration.copyWith(
                  hintText: "Enter your email address",
                  labelText: "Email Address",
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmailAddress,
                onSaved: (String val) {
                  _emailAddress = val;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                height: 50.0,
                child: ButtonTheme(
                  child: new RaisedButton(
                    elevation: 10,
                    color: Colors.red[900],
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          'Reset now',
                          style: new TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    onPressed: _validateInputs,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _validateInputs() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _resetPassword();
    } else {
      setState(() => _autoValidate = true);
    }
  }

  Future<bool> _prompt(BuildContext context) {
    return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: new Text('Password Reset'),
            content: new Text(
                'You will shortly receive an email containing further instructions to continue with the password reset process.'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text('Back To Login'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _validateEmailAddress(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter a valid Email Address';
    else
      return null;
  }

  Future _resetPassword() async {
    await _auth.sendPasswordResetEmail(email: _emailAddress);
    await _prompt(context);
    Navigator.of(context).pop();
  }
}
