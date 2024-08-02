import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegSelectRoleScreen extends StatelessWidget {
  const RegSelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 32.h,
                  left: 64.w,
                  right: 64.w,
                ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.r,
                          vertical: 10.r,
                        ),
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
                            '본인의 신분에 맞게 선택해주세요',
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
                        Navigator.pushNamed(context, '/reg_student_screen');
                      },
                      icon: SvgPicture.asset(
                        width: 180.r,
                        height: 206.r,
                        'assets/cards/sign_in_user.svg',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70.w,
                  ),
                  SizedBox(
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/reg_super_screen');
                      },
                      icon: SvgPicture.asset(
                        width: 180.r,
                        height: 206.r,
                        'assets/cards/sign_in_manager.svg',
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}
