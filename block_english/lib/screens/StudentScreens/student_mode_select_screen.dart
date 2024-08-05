import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/size_config.dart';
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
              padding: EdgeInsets.only(
                top: 32 * SizeConfig.scales,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '학습 모드를 선택해줘!',
                        style: TextStyle(
                          fontSize: 20 * SizeConfig.scales,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '혼자 하고 싶어? 같이 하고 싶어?',
                        style: TextStyle(
                          fontSize: 14 * SizeConfig.scales,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 42 * SizeConfig.scales),
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
                            width: 180 * SizeConfig.scales,
                            height: 206 * SizeConfig.scales,
                            'assets/cards/180_206_card.svg',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70 * SizeConfig.scales,
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
                            width: 180 * SizeConfig.scales,
                            height: 206 * SizeConfig.scales,
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
