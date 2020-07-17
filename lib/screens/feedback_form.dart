import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vilmod/components/logo.dart';
import 'package:vilmod/models/feedback.dart';
import 'package:vilmod/models/user.dart';
import 'package:vilmod/services/database.dart';
import 'package:vilmod/services/feedback_service.dart';
import 'package:vilmod/widgets/styles.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  String category;
  String title;
  String description;
  String status;

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Feedback'),
      ),
      body: StreamBuilder<User>(
          stream: DatabaseService(uid: user?.uid).userData,
          builder: (context, snapshot) {
            var user = snapshot.data;
            return Center(
              child: Container(
                color: Colors.grey[200],
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: FormBuilder(
                    key: _fbKey,
                    autovalidate: false,
                    child: Column(
                      children: <Widget>[
                        _buildSizedBox(30),
                        Logo2(),
                        _buildSizedBox(30),
                        _buildTitle(),
                        _buildSizedBox(30),
                        _buildOptions(),
                        _buildSizedBox(20),
                        _buildTitleField(),
                        _buildSizedBox(20),
                        _buildDescriptionField(),
                        _buildSizedBox(20),
                        _submitButton(user?.uid, user?.emailAddress),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildOptions() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: FormBuilderDropdown(
        attribute: "category",
        decoration: textFormFieldDecoration.copyWith(
            labelText: "Enter category",
            hintText: "Category",
            prefixIcon: Icon(Icons.radio_button_checked)),
        hint: Text('Select category'),
        validators: [FormBuilderValidators.required()],
        onChanged: (value) {
          category = value;
        },
        items: ['Bug', 'General', 'Suggestion']
            .map((gender) =>
                DropdownMenuItem(value: gender, child: Text("$gender")))
            .toList(),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Center(
        child: Text(
          'Fill in the information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: FormBuilderTextField(
        attribute: "title",
        decoration: textFormFieldDecoration.copyWith(
            labelText: "Enter Title",
            hintText: "Title (Optional)",
            prefixIcon: Icon(Icons.subject)),
        onChanged: (value) {
          title = value;
        },
        maxLines: 2,
        validators: [
          //FormBuilderValidators.required(),
          FormBuilderValidators.max(255),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: FormBuilderTextField(
        attribute: "title",
        decoration: textFormFieldDecoration.copyWith(
            labelText: "Enter Description",
            hintText: "Description (Optional)",
            prefixIcon: Icon(Icons.description)),
        maxLines: 5,
        onChanged: (value) {
          description = value;
        },
        validators: [
          // FormBuilderValidators.required(),
          FormBuilderValidators.max(255),
        ],
      ),
    );
  }

  Widget _buildSizedBox(double _height) {
    return SizedBox(
      height: _height,
    );
  }

  Widget _submitButton( uid, email) {
    return Container(
      height: 50,
      width: 200,
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: RaisedButton(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0)),
        //elevation: 10,
        color: Colors.red[900],
        //borderSide: BorderSide(color: Colors.white),
        child: Text(
          'Submit',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: () async {
          print(uid);
          print(email);
          FeedbackService feedbackService = FeedbackService();
          feedbackService.addFeedback(
            FeedBack(
              email: ''+email.toString(),
              userUid: ''+uid.toString(),
              title: title,
              description: description,
              category: category,
              status: 'Open',
              dateCreated: DateTime.now(),
            ),
          );
          showFloatingFlushBar(context);
        },
      ),
    );
  }

  void showFloatingFlushBar(BuildContext context) {
    Flushbar(
      //aroundPadding: EdgeInsets.all(10),
      borderRadius: 10,
      backgroundGradient: LinearGradient(
        colors: [Colors.green.shade900, Colors.green.shade600],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      duration: Duration(milliseconds: 1500),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(
        Icons.add_shopping_cart,
        color: Colors.white,
      ),
      shouldIconPulse: true,
      title: 'Feedback submitted successfully',
      message: 'Thank you for the feedback.',
    )..show(context).then((value) => Navigator.of(context)
        .pushNamedAndRemoveUntil(
            '/home_page', (Route<dynamic> route) => false));
  }
}
