import 'package:flutter/material.dart';

final textFormFieldDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderRadius: new BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Colors.black,
      width: 1,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: new BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Colors.black,
      width: 1,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
    borderSide: BorderSide(width: 1, color: Colors.red),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
    borderSide: BorderSide(width: 1, color: Colors.red),
  ),
  border: new OutlineInputBorder(
    borderRadius: new BorderRadius.circular(10),
    borderSide: new BorderSide(color: Colors.black, width: 1),
  ),
);
