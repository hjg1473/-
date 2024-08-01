import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/device_scale.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentMainScreen extends ConsumerWidget {
  const StudentMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20.0 * DeviceScale.scaleHeight(context),
                  left: 50.0 * DeviceScale.scaleWidth(context),
                ),
                child: ClipOval(
                  child: Material(
                    color: const Color(0xFF5D5D5D),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                        width: 48 * DeviceScale.scaleWidth(context),
                        height: 48 * DeviceScale.scaleHeight(context),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.only(
                    top: 20.0 * DeviceScale.scaleHeight(context)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/season_block.svg',
                      height: 45 * DeviceScale.scaleHeight(context),
                      width: 128 * DeviceScale.scaleWidth(context),
                    ),
                    Text(
                      seasonToString(ref.watch(statusProvider).season),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18 * DeviceScale.scaleHeight(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/stud_step_select_screen'),
                    icon: SvgPicture.asset(
                      'assets/cards/student_main_1.svg',
                      width: 230 * DeviceScale.scaleWidth(context),
                      height: 207 * DeviceScale.scaleHeight(context),
                    ),
                  ),
                  SizedBox(
                    width: 12 * DeviceScale.scaleWidth(context),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/cards/student_main_2.svg',
                      width: 205 * DeviceScale.scaleWidth(context),
                      height: 207 * DeviceScale.scaleHeight(context),
                    ),
                  ),
                  SizedBox(
                    width: 12 * DeviceScale.scaleWidth(context),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/cards/student_main_3.svg',
                      width: 205 * DeviceScale.scaleWidth(context),
                      height: 207 * DeviceScale.scaleHeight(context),
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
