import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegPwQuestionScreen extends StatefulWidget {
  const RegPwQuestionScreen({super.key});

  @override
  State<RegPwQuestionScreen> createState() => _RegPwQuestionScreenState();
}

class _RegPwQuestionScreenState extends State<RegPwQuestionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFD1FCFE),
        body: SingleChildScrollView(
          child: SizedBox(
            height: 1.sh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 307.r,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 32.r,
                      left: 64.r,
                      right: 64.r,
                    ),
                    child: Column(
                      children: [
                        Stack(
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
                                    '비밀번호 찾기 질문 설정',
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '비밀번호 분실 시 사용될 질문과 답을 선택해 주세요',
                                    style: TextStyle(
                                      fontSize: 14.r,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0x88000000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // 질문/ 답변
                      ],
                    ),
                  ),
                ),
                const SquareButton(
                  text: '회원가입',
                  onPressed: null,
                ),
              ],
            ),
          ),
        ));
  }
}
