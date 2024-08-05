import 'dart:math';

import 'package:flutter/material.dart';

class SizeConfig {
  static const baseDeviceWidth = 812;
  static const baseDeviceHeight = 375;
  static late double fullWidth;
  static late double fullHeight;
  static late double scaleWidth;
  static late double scaleHeight;
  static late double scales;

  void init(BuildContext context) {
    fullWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewPadding.horizontal;
    fullHeight = MediaQuery.of(context).size.height;
    scaleWidth = fullWidth / baseDeviceWidth;
    scaleHeight = fullHeight / baseDeviceHeight;
    scales = min(scaleWidth, scaleHeight);
  }
}
