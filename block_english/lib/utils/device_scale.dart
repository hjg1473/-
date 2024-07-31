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
}
