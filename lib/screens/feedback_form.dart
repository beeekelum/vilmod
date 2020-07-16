import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vilmod/widgets/styles.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Feedback'),
      ),
      body: Center(
        child: Container(
          color: Colors.grey[200],
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: FormBuilder(
              key: _fbKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  _buildSizedBox(30),
                  _buildTitle(),
                  _buildSizedBox(30),
                  _buildOptions(),
                  _buildSizedBox(20),
                  _buildTitleField(),
                  _buildSizedBox(20),
                  _buildDescriptionField(),
                  _buildSizedBox(20),
                  _submitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(){
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0),
      child: FormBuilderDropdown(
        attribute: "category",
        decoration: textFormFieldDecoration.copyWith(
            labelText: "Enter category",
            hintText: "Category",
            prefixIcon: Icon(Icons.radio_button_checked)
        ),
        hint: Text('Select category'),
        validators: [FormBuilderValidators.required()],
        items: ['Bug', 'General', 'Suggestion']
            .map((gender) => DropdownMenuItem(
            value: gender,
            child: Text("$gender")
        )).toList(),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0),
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
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0),
      child: FormBuilderTextField(
        attribute: "title",
        decoration: textFormFieldDecoration.copyWith(
            labelText: "Enter Title",
            hintText: "Title (Optional)",
            prefixIcon: Icon(Icons.subject)
        ),
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
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0),
      child: FormBuilderTextField(
        attribute: "title",
        decoration: textFormFieldDecoration.copyWith(
            labelText: "Enter Description",
            hintText: "Description (Optional)",
            prefixIcon: Icon(Icons.description)
        ),
        maxLines: 5,
        validators: [
         // FormBuilderValidators.required(),
          FormBuilderValidators.max(255),
        ],
      ),
    );
  }

  Widget _buildSizedBox(double _height){
    return SizedBox(
      height: _height,
    );
  }

  Widget _submitButton(){
    return Container(
      height: 50,
      width: 200,
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: RaisedButton(
        shape: new RoundedRectangleBorder(
            borderRadius:
            new BorderRadius.circular(10.0)),
        //elevation: 10,
        color: Colors.red[900],
        //borderSide: BorderSide(color: Colors.white),
        child: Text(
          'Submit',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        onPressed: () async {

        },
      ),
    );
  }
}
