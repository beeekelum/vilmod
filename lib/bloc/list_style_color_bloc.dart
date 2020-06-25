import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ColorBloc extends BlocBase {
  ColorBloc();

  //stream that receives a number and changes the count
  var _coloController = BehaviorSubject<Color>.seeded(Colors.white);

//output
  Stream<Color> get colorStream => _coloController.stream;

//input
  Sink<Color> get colorSink => _coloController.sink;

  setColor(Color color) {
    colorSink.add(color);
  }

  //dispose will be called automatically by closing its streams
  @override
  void dispose() {
    _coloController.close();
    super.dispose();
  }
}
