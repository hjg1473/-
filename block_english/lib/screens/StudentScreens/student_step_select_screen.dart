import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/device_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentStepSelectScreen extends ConsumerStatefulWidget {
  const StudentStepSelectScreen({super.key});

  @override
  ConsumerState<StudentStepSelectScreen> createState() =>
      _StudentStepSelectScreenState();
}

class _StudentStepSelectScreenState
    extends ConsumerState<StudentStepSelectScreen> {
  int selectedLevel = 0;

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
            Positioned(
              top: 36 * DeviceScale.scaleHeight(context),
              left: 324 * DeviceScale.scaleWidth(context),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF93E54C),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0 * DeviceScale.scaleWidth(context),
                      vertical: 10.0 * DeviceScale.scaleHeight(context),
                    ),
                    child: Text(
                      levellist[selectedLevel],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10 * DeviceScale.scaleWidth(context),
                  ),
                  Text(
                    'Level ${selectedLevel + 1}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
