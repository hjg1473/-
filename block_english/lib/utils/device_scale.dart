import 'package:flutter/material.dart';

class DeviceScale {
  static const baseDeviceWidth = 812;
  static const baseDeviceHeight = 375;

  static Size screenSize(BuildContext context) {
    return Size(
        MediaQuery.of(context).size.width -
            MediaQuery.of(context).viewPadding.horizontal,
        MediaQuery.of(context).size.height);
  }

  static double scaleWidth(BuildContext context) {
    return screenSize(context).width / baseDeviceWidth;
  }

  static double scaleHeight(BuildContext context) {
    return screenSize(context).height / baseDeviceHeight;
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
