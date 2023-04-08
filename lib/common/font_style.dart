import 'package:flutter/material.dart';

abstract class AppFontStyle {
  static String latoFontFamily = 'Lato';

  static TextStyle fontLato(
      {Color color = Colors.black, required double fontSize, FontWeight fontWeight = FontWeight.normal,double? height}) {
    return TextStyle(color: color, fontFamily: latoFontFamily, fontSize: fontSize, fontWeight: fontWeight,height: height);
  }
}
