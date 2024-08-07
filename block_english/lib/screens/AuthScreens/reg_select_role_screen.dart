import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegSelectRoleScreen extends StatelessWidget {
  const RegSelectRoleScreen({super.key});

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
                  FilledButton.icon(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 16.r,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ).r,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.black,
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '나는 어떤 사용자인가요?',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '사용자를 선택해 주세요',
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
                          arguments: 'student');
                    },
                    icon: SvgPicture.asset(
                      width: 180.r,
                      height: 206.r,
                      'assets/cards/sign_in_user.svg',
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
                      Navigator.pushNamed(
                        context,
                        '/reg_super_type_screen',
                      );
                    },
                    icon: SvgPicture.asset(
                      width: 180.r,
                      height: 206.r,
                      'assets/cards/sign_in_manager.svg',
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
