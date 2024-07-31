import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/device_scale.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentModeSelectScreen extends ConsumerWidget {
  const StudentModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        '학습 모드를 선택해줘!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '혼자 하고 싶어? 같이 하고 싶어?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: IconButton(
                          onPressed: () {
                            ref
                                .watch(statusProvider)
                                .setStudentMode(StudentMode.PRIVATE);
                            Navigator.of(context)
                                .pushNamed('/stud_season_select_screen');
                          },
                          icon: SvgPicture.asset(
                            width: 180 * DeviceScale.scaleWidth(context),
                            height: 206 * DeviceScale.scaleHeight(context),
                            'assets/cards/180_206_card.svg',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70 * DeviceScale.scaleWidth(context),
                      ),
                      SizedBox(
                        child: IconButton(
                          onPressed: () {
                            ref
                                .watch(statusProvider)
                                .setStudentMode(StudentMode.GROUP);
                            Navigator.of(context)
                                .pushNamed('/stud_season_select_screen');
                          },
                          icon: SvgPicture.asset(
                            width: 180 * DeviceScale.scaleWidth(context),
                            height: 206 * DeviceScale.scaleHeight(context),
                            'assets/cards/180_206_card.svg',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
