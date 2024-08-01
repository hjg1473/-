import 'dart:math';

import 'package:flutter/material.dart';

class DeviceScale {
  static const baseDeviceWidth = 812;
  static const baseDeviceHeight = 375;

  static double scaleWidth(BuildContext context) {
    return MediaQuery.of(context).size.width / baseDeviceWidth;
  }

  static double scaleHeight(BuildContext context) {
    return MediaQuery.of(context).size.height / baseDeviceHeight;
  }

  static double scaleSize(BuildContext context) {
    return min(MediaQuery.of(context).size.width / baseDeviceWidth,
        MediaQuery.of(context).size.height / baseDeviceHeight);
  }

  static double horizontalPadding(BuildContext context) {
    if (MediaQuery.of(context).size.width < 700) {
      return 25 * scaleWidth(context);
    }
    return 65 * scaleWidth(context);
  }

  static double verticalPadding(BuildContext context) {
    return 30 * scaleHeight(context);
  }

  static EdgeInsets scaffoldPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(horizontalPadding(context),
        verticalPadding(context), horizontalPadding(context), 0);
  }

  static double squareButtonHeight(BuildContext context) {
    return 60 * scaleHeight(context);
  }
}
