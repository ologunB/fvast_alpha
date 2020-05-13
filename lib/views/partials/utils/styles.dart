import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Styles {
  static Color appPrimaryColor = Color.fromRGBO(25, 167, 241, 1);
  static Color appAccentColor = Colors.cyan[600];
  static Color appCanvasColor = Colors.white;
  static Color appBackground = Colors.blue;
  static Color commonDarkBackground = Colors.grey[200];
  static Color commonDarkCardBackground = Colors.grey[200]; // #1e2d3b

  static InputDecoration input = InputDecoration(
    fillColor: Colors.white,
    focusColor: Colors.grey[900],
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
    border: OutlineInputBorder(
      gapPadding: 1.0,
      borderSide: BorderSide(color: Colors.grey[600], width: 1.0),
    ),
    hintStyle: TextStyle(
      color: Colors.grey[600],
    ),
  );
}

void moveToReplace(BuildContext context, whereTo) {
  Navigator.pushReplacement(
      context, CupertinoPageRoute(builder: (context) => whereTo));
}

void moveTo(BuildContext context, whereTo) {
  Navigator.push(context, CupertinoPageRoute(builder: (context) => whereTo));
}
