import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class StudentModeSelectScreen extends ConsumerWidget {
  const StudentModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SizedBox(
        height: 1.sh,
        child: Padding(
          padding: EdgeInsets.only(
            top: 32.r,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '학습 모드를 선택해줘!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '혼자 하고 싶어? 같이 하고 싶어?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
              const Spacer(),
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
                      icon: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SvgPicture.asset(
                            width: 180.r,
                            height: 206.r,
                            'assets/cards/student_mode_single.svg',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0).r,
                            child: SizedBox(
                              width: 205.r,
                              height: 142.r,
                              child:
                                  Lottie.asset('assets/lottie/motion_27.json'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70.r,
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
                      icon: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SvgPicture.asset(
                            width: 180.r,
                            height: 206.r,
                            'assets/cards/student_mode_group.svg',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0).r,
                            child: SizedBox(
                              width: 205.r,
                              height: 142.r,
                              child:
                                  Lottie.asset('assets/lottie/motion_26.json'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
