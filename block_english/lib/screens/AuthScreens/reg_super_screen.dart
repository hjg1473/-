import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/device_scale.dart';
import 'package:block_english/widgets/reg_input_box.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegSuperScreen extends ConsumerStatefulWidget {
  const RegSuperScreen({super.key});

  @override
  ConsumerState<RegSuperScreen> createState() => _SuperState();
}

class _SuperState extends ConsumerState<RegSuperScreen> {
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
  bool isObsecure = true;
  bool isObsecure2 = true;

  onDoubleCheckPressed() {
    username = usernameController.text;
    if (username == '') {
      setState(() {
        usernameError = '이메일을 입력해주세요';
        isChecked = false;
      });
      return;
    } else if (!username.contains('@')) {
      setState(() {
        usernameError = '이메일 형식이 아닙니다';
        isChecked = false;
      });
      return;
    }

    //TODO: double check
    setState(() {
      usernameError = '사용 가능한 이메일입니다';
      isChecked = true;
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
    bool onError = false;

    name = nameController.text;
    password = passwordController.text;
    password2 = password2Controller.text;

    if (name == '') {
      setState(() {
        nameError = '이름을 입력해주세요';
      });
      onError = true;
    }

    if (!isChecked) {
      setState(() {
        usernameError = '중복확인을 해주세요';
      });
      onError = true;
    } else if (username != usernameController.text) {
      setState(() {
        usernameError = '중복확인을 다시 해주세요';
        isChecked = false;
        usernameController.clear();
        username = '';
      });
      onError = true;
    }

    if (password == '') {
      setState(() {
        passwordError = '비밀번호를 입력해주세요';
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

    setState(() {
      nameError = '';
      passwordError = '';
      password2Error = '';
    });

    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RegSuperNextScreen(name, username, password)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 1.sh,
            child: Column(
              children: [
                SizedBox(
                  height: 307.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 32.h,
                      left: 64.w,
                      right: 64.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
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
                                '돌아가기',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
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
                                    '관리자 회원가입',
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '이름과 이메일을 알맞게 입력해주세요',
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
                                  labelText: '이름',
                                  hintText: '한글 또는 영문만 입력해주세요',
                                  controller: nameController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]')),
                                  ],
                                  errorMessage: nameError,
                                ),
                                SizedBox(width: 20.w),
                                RegInputBox(
                                  labelText: '이메일',
                                  hintText: '사용할 이메일을 입력해주세요',
                                  controller: usernameController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9@.-]')),
                                  ],
                                  errorMessage: usernameError,
                                  doubleCheck: true,
                                  onCheckPressed: onDoubleCheckPressed,
                                  success: isChecked,
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                RegInputBox(
                                  labelText: '비밀번호',
                                  hintText: '영문/숫자 조합, 8자 이상 입력해주세요',
                                  controller: passwordController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  errorMessage: passwordError,
                                  obscureText: isObsecure,
                                  isSelected: !isObsecure,
                                  onEyePressed: onEyePressed,
                                ),
                                SizedBox(width: 20.w),
                                RegInputBox(
                                  labelText: '비밀번호 확인',
                                  hintText: '비밀번호를 다시 입력해주세요',
                                  controller: password2Controller,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  errorMessage: password2Error,
                                  obscureText: isObsecure2,
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
                  text: '다음',
                  onPressed: onNextPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegSuperNextScreen extends ConsumerStatefulWidget {
  const RegSuperNextScreen(this.name, this.username, this.password,
      {super.key});

  final String name;
  final String username;
  final String password;

  @override
  ConsumerState<RegSuperNextScreen> createState() => _RegSuperNextScreenState();
}

class _RegSuperNextScreenState extends ConsumerState<RegSuperNextScreen> {
  String phoneNumber = '';
  String verifyNumber = '';

  TextEditingController phonenumberController = TextEditingController();
  TextEditingController verifynumberController = TextEditingController();

  String phoneNumberError = '';
  String verifyNumberError = '';

  bool isChecked = false;

  onSendPressed() async {
    phoneNumber = phonenumberController.text;
    if (phoneNumber == '') {
      setState(() {
        phoneNumberError = '전화번호를 입력해주세요';
      });
      return;
    }

    phoneNumberError = '';
    final reponse =
        await ref.watch(authServiceProvider).postAuthGetNumber(phoneNumber);

    reponse.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증번호 전송 실패\n다시 시도해 주세요'),
          ),
        );
      }
    }, (getNumberResponseModel) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증번호가 전송되었습니다.'),
          ),
        );
        setState(() {
          isChecked = false;
          verifyNumberError = '';
          verifynumberController.clear();
        });
      }
    });
  }

  onCheckPressed() async {
    verifyNumber = verifynumberController.text;
    if (verifyNumber == '') {
      setState(() {
        verifyNumberError = '인증번호를 입력해주세요';
        isChecked = false;
      });
      return;
    }

    // TODO: verify number
    final response = await ref
        .watch(authServiceProvider)
        .postAuthVerifyNumber(phoneNumber, verifyNumber);

    response.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('인증번호가 틀렸습니다'),
            ),
          );
        }
      },
      (verifyResponseModel) {
        if (mounted) {
          setState(() {
            isChecked = true;
            verifyNumberError = '인증이 완료되었습니다';
          });
        }
      },
    );
  }

  onRegisterPressed() async {
    if (!isChecked) {
      setState(() {
        verifyNumberError = '인증을 완료해 주세요';
      });
      return;
    }

    final result = await ref.watch(authServiceProvider).postAuthRegister(
        widget.name, widget.username, widget.password, 1, 'super');

    result.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('가입 다시해'),
          ),
        );

        setState(() {
          phoneNumberError = '';
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 1.sh,
            child: Column(
              children: [
                SizedBox(
                  height: 307.h,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 32.h,
                      left: 64.w,
                      right: 64.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
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
                                '돌아가기',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
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
                                    '관리자 회원가입',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '전화번호를 인증해주세요',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RegInputBox(
                                  width: 510.r,
                                  labelText: '전화번호',
                                  hintText: '- 없이 숫자만 입력해주세요',
                                  controller: phonenumberController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  errorMessage: phoneNumberError,
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    fixedSize: Size(158.r, 64.r),
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: onSendPressed,
                                  child: Text(
                                    '인증번호 전송',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            RegInputBox(
                              width: 684.r,
                              labelText: '인증번호',
                              hintText: '인증번호 N자리를 정확히 입력해 주세요',
                              controller: verifynumberController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              errorMessage: verifyNumberError,
                              verify: true,
                              onCheckPressed: onCheckPressed,
                              success: isChecked,
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                SquareButton(text: '회원가입', onPressed: onRegisterPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
