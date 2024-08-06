import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegSuperTypeScreen extends StatelessWidget {
  const RegSuperTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFD1FCFE),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 32,
                left: 64,
                right: 64,
              ).r,
              child: Stack(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: SvgPicture.asset(
                      'assets/buttons/round_back_button.svg',
                      width: 48.r,
                      height: 48.r,
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '관리자의 유형을 선택해 주세요',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '개인 관리와 그룹 관리를 구분해 주세요',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0x88000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reg_get_info_screen',
                          arguments: 'parent');
                    },
                    icon: SvgPicture.asset(
                      width: 180.r,
                      height: 206.r,
                      'assets/cards/sign_in_parent.svg',
                    ),
                    highlightColor: Colors.transparent,
                  ),
                ),
                SizedBox(
                  width: 70.r,
                ),
                SizedBox(
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reg_get_info_screen',
                          arguments: 'teacher');
                    },
                    icon: SvgPicture.asset(
                      width: 180.r,
                      height: 206.r,
                      'assets/cards/sign_in_teacher.svg',
                    ),
                    highlightColor: Colors.transparent,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ));
  }
}
