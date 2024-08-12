import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:block_english/models/AuthModel/reg_info_model.dart';
import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegPwQuestionScreen extends ConsumerStatefulWidget {
  const RegPwQuestionScreen({super.key});

  @override
  ConsumerState<RegPwQuestionScreen> createState() =>
      _RegPwQuestionScreenState();
}

class _RegPwQuestionScreenState extends ConsumerState<RegPwQuestionScreen> {
  late RegInfoModel regInfo;
  int questionType = -1;
  String answer = '';
  bool isFilled = false;

  onRegisterPressed() async {
    final result = await ref.watch(authServiceProvider).postAuthRegister(
          regInfo.name,
          regInfo.username,
          regInfo.password,
          regInfo.role,
          questionType,
          answer,
        );

    result.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.detail.toString()),
          ),
        );
      }
    }, (regResponseModel) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login_screen',
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    regInfo = ModalRoute.of(context)!.settings.arguments as RegInfoModel;
    return Scaffold(
        backgroundColor: const Color(0xFFD1FCFE),
        body: SingleChildScrollView(
          child: SizedBox(
            height: 1.sh,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 307.r,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 32,
                      left: 64,
                      right: 64,
                    ).r,
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
                        const Spacer(flex: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '질문',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 29.r),
                            SizedBox(
                              width: 357.r,
                              //height: 50.r,
                              child: CustomDropdown(
                                hintText: '질문을 선택해 주세요',
                                items: questionList,
                                onChanged: (value) => setState(() {
                                  questionType = questionList.indexOf(value!);
                                }),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.r),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '답변',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 29.r),
                            SizedBox(
                              width: 357.r,
                              //height: 50.r,
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 18.r,
                                    vertical: 16.r,
                                  ),
                                  hintText: '답변을 입력해 주세요',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFFADADAD),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12).r,
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) => setState(() {
                                  answer = value;
                                  isFilled =
                                      answer.isNotEmpty && questionType != -1;
                                }),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(flex: 13),
                      ],
                    ),
                  ),
                ),
                SquareButton(
                  text: '회원가입',
                  onPressed: isFilled ? onRegisterPressed : null,
                ),
              ],
            ),
          ),
        ));
  }
}
