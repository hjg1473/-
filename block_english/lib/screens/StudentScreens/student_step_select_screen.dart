import 'package:block_english/utils/device_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentStepSelectScreen extends StatelessWidget {
  const StudentStepSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 32 * DeviceScale.scaleHeight(context),
              left: 44 * DeviceScale.scaleWidth(context),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                icon: SvgPicture.asset(
                  'assets/buttons/backbutton_label.svg',
                  width: 133 * DeviceScale.scaleWidth(context),
                  height: 44 * DeviceScale.scaleHeight(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
