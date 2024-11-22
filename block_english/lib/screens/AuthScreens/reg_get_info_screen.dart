import 'package:block_english/models/AuthModel/reg_info_model.dart';
import 'package:block_english/services/auth_service.dart';
import 'package:block_english/widgets/reg_input_box.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegGetInfoScreen extends ConsumerStatefulWidget {
  const RegGetInfoScreen({super.key});

  @override
  ConsumerState<RegGetInfoScreen> createState() => _RegStudentScreenState();
}

class _RegStudentScreenState extends ConsumerState<RegGetInfoScreen> {
  String role = '';
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

  bool nextDisable = true;

  bool dupCheckDisable = true;
  bool dupChecked = false;
  bool nameChecked = false;
  bool passwordChecked = false;
  bool isObsecure = true;
  bool isObsecure2 = true;

  onNameChanged() {
    name = nameController.text;
    if (name.isNotEmpty) {
      setState(() {
        nameChecked = true;
        if (passwordChecked && dupChecked) {
          nextDisable = false;
        }
      });
    } else {
      setState(() {
        nameChecked = false;
        nextDisable = true;
      });
    }
  }

  onPasswordChanged() {
    password = passwordController.text;
    password2 = password2Controller.text;

    if (password.length > 7 && password2.isNotEmpty) {
      if (password == password2) {
        setState(() {
          passwordError = '';
          password2Error = '';
          passwordChecked = true;
          if (nameChecked && dupChecked) {
            nextDisable = false;
          }
        });
      } else {
        setState(() {
          passwordError = '';
          password2Error = '비밀번호가 일치하지 않습니다';
          passwordChecked = false;
          nextDisable = true;
        });
      }
    } else if (password2.isEmpty) {
      setState(() {
        password2Error = '';
        passwordChecked = false;
        nextDisable = true;
      });
    } else {
      setState(() {
        if (password.length < 8) {
          passwordError = '비밀번호는 8자 이상이어야 합니다';
        } else {
          passwordError = '';
        }
        passwordChecked = false;
        nextDisable = true;
      });
    }
  }

  onDupCheckChanged() {
    if (dupChecked && username != usernameController.text) {
      setState(() {
        dupChecked = false;
        usernameError = '중복확인을 다시 해 주세요';
        nextDisable = true;
      });
      return;
    }
    username = usernameController.text;
    if (username.length < 6) {
      setState(() {
        dupCheckDisable = true;
      });
    } else {
      setState(() {
        dupCheckDisable = false;
      });
    }
  }

  onDupCheckPressed() async {
    username = usernameController.text;

    final response = await ref
        .watch(authServiceProvider)
        .postAuthUsernameDuplication(username);
    response.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아이디 중복확인 실패'),
          ),
        );
      }
    }, (dupResponseModel) {
      if (dupResponseModel.available == 1) {
        setState(() {
          dupChecked = true;
          usernameError = '사용 가능한 아이디입니다';
          if (nameChecked && passwordChecked) {
            nextDisable = false;
          }
        });
      } else {
        setState(() {
          dupChecked = false;
          usernameError = '이미 사용중인 아이디입니다';
        });
      }
    });
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

  onNextPressed() {
    Navigator.of(context).pushNamed(
      '/reg_pw_question_screen',
      arguments: RegInfoModel(
        name: name,
        username: username,
        password: password,
        role: role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    role = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: const Color(0xFFD1FCFE),
      body: SingleChildScrollView(
        child: SizedBox(
          height: 1.sh,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                  role == 'student' ? '학습자 회원가입' : '관리자 회원가입',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '아이디와 비밀번호를 설정해 주세요',
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
                                dupCheck: true,
                                onChanged: onDupCheckChanged,
                                onCheckPressed:
                                    dupCheckDisable ? null : onDupCheckPressed,
                                success: dupChecked,
                              ),
                              SizedBox(width: 20.r),
                              RegInputBox(
                                labelText: '이름',
                                hintText: '실명으로 입력해 주세요',
                                controller: nameController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]')),
                                ],
                                errorMessage: nameError,
                                onChanged: onNameChanged,
                              ),
                            ],
                          ),
                          SizedBox(height: 16.r),
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
                                onChanged: onPasswordChanged,
                                obscureText: true,
                                isObsecure: isObsecure,
                                onEyePressed: onEyePressed,
                              ),
                              SizedBox(width: 20.r),
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
                                onChanged: onPasswordChanged,
                                obscureText: true,
                                isObsecure: isObsecure2,
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
                text: '다음으로',
                onPressed: nextDisable ? null : onNextPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
