import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class StudentModeSelectScreen extends ConsumerWidget {
  const StudentModeSelectScreen({super.key});

  Future<dynamic> _showFailDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.02).r,
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          8,
        ).r,
        title: Center(
          child: Text(
            '입장 실패',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20).r,
        content: Text(
          '소속되어 있는 그룹이 없어서\n지금은 입장할 수 없어요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA7A7A7),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          20,
          32,
          20,
          20,
        ).r,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 57,
              ).r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.02).r,
              ),
              backgroundColor: const Color(0xFF919191),
            ),
            child: Text(
              '나갈래요',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                  '/stud_add_super_screen',
                  arguments: true);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 31.5,
              ).r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.02).r,
              ),
              backgroundColor: const Color(0xFF93E54C),
            ),
            child: Text(
              '그룹 핀코드 입력',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                        if (ref.watch(statusProvider).teamId == null) {
                          _showFailDialog(context);
                          return;
                        }
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
