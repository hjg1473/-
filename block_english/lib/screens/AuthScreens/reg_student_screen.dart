import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/size_config.dart';
import 'package:block_english/widgets/reg_input_box.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegStudentScreen extends ConsumerStatefulWidget {
  const RegStudentScreen({super.key});

  @override
  ConsumerState<RegStudentScreen> createState() => _StudState();
}

class _StudState extends ConsumerState<RegStudentScreen> {
  String name = '';
  String username = '';
  String password = '';
  String password2 = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2Controller = TextEditingController();

  String nameError = '';
  String usernameError = '';
  String passwordError = '';
  String password2Error = '';

  bool isChecked = false;
  bool isObsecure = false;
  bool isObsecure2 = false;

  onDoubleCheckPressed() {
    username = usernameController.text;
    if (username == '') {
      setState(() {
        usernameError = '아이디를 입력해 주세요';
        isChecked = false;
      });
      return;
    }

    if (username.length < 6) {
      setState(() {
        usernameError = '6자 이상 입력해 주세요';
        isChecked = false;
      });
      return;
    }

    //TODO: double check
    isChecked = true;
  }

  onEyePressed() {
    setState(() {
      isObsecure = !isObsecure;
    });
  }

  onEye2Pressed() {
    setState(() {
      isObsecure2 = !isObsecure2;
    });
  }

  onRegisterPressed() async {
    bool onError = false;

    name = nameController.text;
    password = passwordController.text;
    password2 = password2Controller.text;

    if (name == '') {
      setState(() {
        nameError = '이름을 입력해 주세요';
      });
      onError = true;
    }

    if (!isChecked) {
      setState(() {
        usernameError = '중복확인을 해 주세요';
      });
      onError = true;
    }

    if (password == '') {
      setState(() {
        passwordError = '비밀번호를 입력해 주세요';
      });
      onError = true;
    } else if (password.length < 8) {
      setState(() {
        passwordError = '8자 이상 입력해주세요';
      });
      onError = true;
    }

    if (password != password2) {
      setState(() {
        password2Error = '비밀번호가 일치하지 않습니다';
        password2Controller.clear();
      });
      onError = true;
    }

    if (onError) {
      return;
    }

    final result = await ref
        .watch(authServiceProvider)
        .postAuthRegister(name, username, password, 1, 'student');

    result.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('가입 다시해'),
          ),
        );
        setState(() {
          nameError = '';
          passwordError = '';
          password2Error = '';
        });
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
    return Scaffold(
      backgroundColor: Colors.amber,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: SizedBox(
            height: SizeConfig.fullHeight,
            child: Column(
              children: [
                SizedBox(
                  height: 307 * SizeConfig.scaleHeight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 32 * SizeConfig.scales,
                      left: 64 * SizeConfig.scales,
                      right: 64 * SizeConfig.scales,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            FilledButton.icon(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 16 * SizeConfig.scales,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: Text(
                                '돌아가기',
                                style: TextStyle(
                                  fontSize: 16 * SizeConfig.scales,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20 * SizeConfig.scales,
                                  vertical: 10 * SizeConfig.scales,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: Colors.black,
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    '학습자 회원가입',
                                    style: TextStyle(
                                      fontSize: 22 * SizeConfig.scales,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '이름과 전화번호를 알맞게 입력해주세요',
                                    style: TextStyle(
                                      fontSize: 14 * SizeConfig.scales,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0x88000000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //TODO: add email check

                            // Positioned(
                            //   right: 0,
                            //   child: FilledButton(
                            //     onPressed: () {},
                            //     style: FilledButton.styleFrom(
                            //       padding: EdgeInsets.symmetric(
                            //         horizontal: 20.r,
                            //         vertical: 10.r,
                            //       ),
                            //       tapTargetSize:
                            //           MaterialTapTargetSize.shrinkWrap,
                            //       backgroundColor: const Color(0xFFB132FE),
                            //     ),
                            //     child: Text(
                            //       '이메일 회원가입',
                            //       style: TextStyle(
                            //         fontSize: 16.sp,
                            //         fontWeight: FontWeight.w400,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RegInputBox(
                                  labelText: '아이디',
                                  hintText: '영문/숫자 조합, 6자 이상 입력해 주세요',
                                  controller: usernameController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]')),
                                  ],
                                  errorMessage: usernameError,
                                  doubleCheck: true,
                                  onCheckPressed: onDoubleCheckPressed,
                                ),
                                SizedBox(width: 20 * SizeConfig.scales),
                                RegInputBox(
                                  labelText: '이름',
                                  hintText: '실명으로 입력해 주세요',
                                  controller: nameController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]')),
                                  ],
                                  errorMessage: nameError,
                                ),
                              ],
                            ),
                            SizedBox(height: 16 * SizeConfig.scales),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RegInputBox(
                                  labelText: '비밀번호',
                                  hintText: '영문/숫자 조합, 8자 이상 입력해 주세요',
                                  controller: passwordController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  errorMessage: passwordError,
                                  obscureText: true,
                                  isSelected: !isObsecure,
                                  onEyePressed: onEyePressed,
                                ),
                                SizedBox(width: 20 * SizeConfig.scales),
                                RegInputBox(
                                  labelText: '비밀번호 확인',
                                  hintText: '비밀번호를 다시 입력해 주세요',
                                  controller: password2Controller,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  errorMessage: password2Error,
                                  obscureText: true,
                                  isSelected: !isObsecure2,
                                  onEyePressed: onEye2Pressed,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                SquareButton(
                  text: '회원가입',
                  onPressed: onRegisterPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
