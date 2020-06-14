import 'package:flutter/material.dart';
import 'package:vilmod/components/constants.dart';
import 'package:vilmod/components/custom_icons.dart';
import 'package:vilmod/components/loading.dart';
import 'package:vilmod/components/logo.dart';
import 'package:vilmod/components/social_icons.dart';
import 'package:vilmod/screens/sign_up_page.dart';
import 'package:vilmod/services/auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vilmod/utils/SizeConfig.dart';
import 'package:vilmod/widgets/styles.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool autoValidate = false;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool loading = false;
  bool passwordVisible;

  String email = '';
  String password = '';
  String error = '';

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : SafeArea(
          child: Scaffold(
              body: Stack(
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          elevation: 5,
                          color: Colors.transparent,
                          shadowColor: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          child: FormBuilder(
                            key: _fbKey,
                            autovalidate: autoValidate,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    _buildSpaceWidget(4),
                                    Logo(),
                                    //_buildSpaceWidget(2),
                                    Text(
                                      'Customer Login',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildSpaceWidget(2),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: FormBuilderTextField(
                                    attribute: "email",
                                    decoration: textFormFieldDecoration.copyWith(
                                      labelText: "Enter Email",
                                      hintText: "Email",
                                      prefixIcon: Icon(Icons.mail)
                                    ),
                                    onChanged: (value) {
                                      email = value;
                                    },
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                    //keyboardType: TextInputType.text,
                                  ),
                                ),
                                _buildSpaceWidget(3),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: FormBuilderTextField(
                                    obscureText: passwordVisible,
                                    decoration: textFormFieldDecoration.copyWith(
                                      hintText: 'Password',
                                      labelText: 'Enter Password',
                                      prefixIcon: Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        color: Colors.black,
                                        onPressed: () {
                                          setState(() {
                                            passwordVisible = !passwordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    maxLines: 1,
                                    validators: [
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.minLength(6,
                                          allowEmpty: false),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    },
                                  ),
                                ),
                                _buildSpaceWidget(2),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pushNamed(context, '/reset_password');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          "Forgot password? Reset",
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _buildSpaceWidget(2),
                                Container(
                                  height: 50,
                                  margin: EdgeInsets.symmetric(horizontal: 50),
                                  child: RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10.0)),
                                    elevation: 10,
                                    color: Colors.red[900],
                                    //borderSide: BorderSide(color: Colors.white),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      if (_fbKey.currentState.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        dynamic result =
                                            await _auth.signInWithEmailAndPassword(
                                                email, password);
                                        if (result == null) {
                                          setState(() {
                                            error =
                                                'Could not sign in with those credentials';
                                            loading = false;
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                                _buildSpaceWidget(2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Don't have an Account?",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 2 * SizeConfig.textMultiplier),
                                    ),
                                    SizedBox(
                                      width: 1 * SizeConfig.widthMultiplier,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => SignUp()));
                                      },
                                      child: Text(
                                        "Register here",
                                        style: TextStyle(
                                            color: Colors.blue[600],
                                            fontSize: 2 * SizeConfig.textMultiplier),
                                      ),
                                    ),
                                  ],
                                ),
                                _buildSpaceWidget(2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    horizontalLine(),
                                    Text(
                                      'Social Login',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    horizontalLine()
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SocialIcon(
                                      colors: [
                                        Color(0xFF102397),
                                        Color(0xFF187adf),
                                        Color(0xFF00eaf8),
                                      ],
                                      iconData: CustomIcons.facebook,
                                      onPressed: () {
                                        // facebookLogin();
                                      },
                                    ),
                                    SocialIcon(
                                      colors: [
                                        Color(0xFFff4f38),
                                        Color(0xFFff355d),
                                      ],
                                      iconData: CustomIcons.googlePlus,
                                      //onPressed: login,
                                    ),
                                    SocialIcon(
                                      colors: [
                                        Color(0xFFD0D0D0),
                                        Color(0xFF808080),
                                      ],
                                      iconData: CustomIcons.phone_iphone,
                                      onPressed: () {
//                            Navigator.of(context)
//                                .pushReplacementNamed('/phonenumpage');
                                      },
                                    )
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                      child: Text(
                                        error,
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
//                Positioned(
//                  top: 30,
//                  right: 20,
//                  child: Row(
//                    children: <Widget>[
//                      FlatButton.icon(
//                        onPressed: () {
//                          widget.toggleView();
//                        },
//                        icon: Icon(Icons.person_add),
//                        label: Text('Register'),
//                        color: Colors.white,
//                        shape: new RoundedRectangleBorder(
//                          borderRadius: new BorderRadius.circular(30.0),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
                ],
              ),
            ),
        );
  }

  Widget _buildSpaceWidget(int height) {
    return SizedBox(
      height: height * SizeConfig.heightMultiplier,
    );
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Container(
          width: 40,
          height: 0.5,
          color: Colors.white,
        ),
      );
}
