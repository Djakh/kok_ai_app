import 'package:flutter/material.dart';

class SizeConfig {
  static late double screenHeight;
  static late double screenWidth;

  static late double heightPercent1;
  static late double widthPercent1;
  static late double rh;
  static late double rw;

  void init(BuildContext context, BoxConstraints constraints) {
    final padding = MediaQuery.of(context).padding;

    screenWidth = constraints.maxWidth;
    screenHeight = constraints.maxHeight - padding.top - padding.bottom;

    heightPercent1 = screenHeight * 0.01;
    widthPercent1 = screenWidth * 0.01;

    rh = heightPercent1 / 9.26;
    rw = widthPercent1 / 4.28;
  }
}
