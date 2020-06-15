import 'package:flutter/material.dart';
import 'package:vilmod/components/constants.dart';
import 'package:vilmod/components/loading.dart';
import 'package:vilmod/components/logo.dart';
import 'package:vilmod/screens/sign_in_page.dart';
import 'package:vilmod/services/auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vilmod/utils/SizeConfig.dart';
import 'package:vilmod/widgets/styles.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;

  SignUp({this.toggleView});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool autoValidate = false;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'ZA';
  PhoneNumber number = PhoneNumber(isoCode: 'ZA');
  bool passwordVisible;

  //text field state
  String email = '';
  String password = '';
  String error = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';

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
              //resizeToAvoidBottomPadding: false,
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
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.1),
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
                          borderRadius: BorderRadius.circular(20),
                          child: FormBuilder(
                            key: _fbKey,
                            autovalidate: autoValidate,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    _buildSpaceWidget(3),
                                    Logo(),
                                    Text(
                                      'Customer Registration',
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
                                    attribute: "first_name",
                                    decoration:
                                        textFormFieldDecoration.copyWith(
                                            hintText: 'First name',
                                            prefixIcon: Icon(Icons.person)),
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        firstName = value;
                                      });
                                    },
                                  ),
                                ),
                                _buildSpaceWidget(2),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: FormBuilderTextField(
                                    attribute: "last_name",
                                    decoration:
                                        textFormFieldDecoration.copyWith(
                                            hintText: 'Last name',
                                            prefixIcon: Icon(Icons.person)),
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        lastName = value;
                                      });
                                    },
                                  ),
                                ),
                                _buildSpaceWidget(2),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: FormBuilderTextField(
                                    attribute: "email",
                                    decoration:
                                        textFormFieldDecoration.copyWith(
                                            labelText: "Enter Email",
                                            hintText: "Email",
                                            prefixIcon: Icon(Icons.mail)),
                                    onChanged: (value) {
                                      setState(() {
                                        email = value;
                                      });
                                    },
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                    //keyboardType: TextInputType.text,
                                  ),
                                ),
                                _buildSpaceWidget(2),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: FormBuilderTextField(
                                    obscureText: passwordVisible,
                                    decoration:
                                        textFormFieldDecoration.copyWith(
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: InternationalPhoneNumberInput(
                                    onInputChanged: (PhoneNumber number) {
                                      print(number.phoneNumber);
                                      phoneNumber =
                                          number.phoneNumber.toString();
                                    },
                                    onInputValidated: (bool value) {
                                      print(value);
                                    },
                                    ignoreBlank: false,
                                    autoValidate: false,
                                    selectorTextStyle:
                                        TextStyle(color: Colors.black),
                                    initialValue: number,
                                    textFieldController: controller,
                                    inputBorder: OutlineInputBorder(),
                                    inputDecoration:
                                        textFormFieldDecoration.copyWith(
                                            labelText: 'Phone number',
                                            prefixIcon: Icon(Icons.phone)),
                                  ),
                                ),
                                _buildSpaceWidget(2),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 50,
                                  margin: EdgeInsets.symmetric(horizontal: 32),
                                  child: RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0)),
                                    elevation: 10,
                                    color: Colors.red[900],
                                    //borderSide: BorderSide(color: Colors.white),
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      if (_fbKey.currentState.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        dynamic result = await _auth
                                            .registerWithEmailAndPassword(
                                                email,
                                                password,
                                                firstName,
                                                lastName,
                                                phoneNumber);
                                        setState(() {
                                          loading = false;
                                          Navigator.pop(context);
                                        });
                                      } else {
                                        setState(() {
                                          autoValidate = true;
                                        });
                                        setState(() {
                                          autoValidate = true;
                                          loading = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                _buildSpaceWidget(2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Already have an Account?",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              2 * SizeConfig.textMultiplier),
                                    ),
                                    SizedBox(
                                      width: 1 * SizeConfig.widthMultiplier,
                                    ),
                                    GestureDetector(
                                      onTap: () {
//                                      Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                              builder: (context) => SignIn()));
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Login here",
                                        style: TextStyle(
                                            color: Colors.blue[600],
                                            fontSize:
                                                2 * SizeConfig.textMultiplier),
                                      ),
                                    ),
                                  ],
                                ),
                                _buildSpaceWidget(2),
                                Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10,
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
//                        icon: Icon(Icons.person),
//                        label: Text('Login'),
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

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'ZA');

    setState(() {
      this.number = number;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _buildSpaceWidget(int height) {
    return SizedBox(
      height: height * SizeConfig.heightMultiplier,
    );
  }
}
