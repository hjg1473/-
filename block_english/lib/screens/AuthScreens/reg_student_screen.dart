import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/reg_input_box.dart';
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
  bool isObsecure = true;
  bool isObsecure2 = true;

  onDoubleCheckPressed() {
    username = usernameController.text;
    if (username == '') {
      setState(() {
        usernameError = '전화번호를 입력해주세요';
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
        nameError = '이름을 입력해주세요';
      });
      onError = true;
    }

    if (!isChecked) {
      setState(() {
        usernameError = '중복확인을 해주세요';
      });
      onError = true;
    }

    if (password == '') {
      setState(() {
        passwordError = '비밀번호를 입력해주세요';
      });
      onError = true;
    }

    if (password != password2) {
      setState(() {
        password2Error = '비밀번호가 일치하지 않습니다';
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
    Size screenSize = MediaQuery.of(context).size;
    var horArea = screenSize.width -
        MediaQuery.of(context).viewPadding.horizontal -
        2 * horPadding;
    var verArea = screenSize.height -
        MediaQuery.of(context).viewPadding.vertical -
        2 * verPadding;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: SingleChildScrollView(
            child: SizedBox(
              height: verArea,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: const Text(
                          '돌아가기',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.minPositive, 40),
                          backgroundColor: Colors.grey[700],
                        ),
                      ),
                      const Spacer(flex: 4),
                      Column(
                        children: [
                          const Text(
                            '학습자 회원가입',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '이름과 전화번호를 알맞게 입력해주세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 3),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.minPositive, 40),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          '이메일 회원가입',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RegInputBox(
                            width: (horArea - 20) / 2,
                            labelText: '이름',
                            hintText: '이름을 입력해주세요',
                            controller: nameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]')),
                            ],
                            errorMessage: nameError,
                          ),
                          RegInputBox(
                            width: (horArea - 20) / 2,
                            labelText: '전화번호',
                            hintText: '전화번호를 입력해주세요',
                            controller: usernameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            errorMessage: usernameError,
                            doubleCheck: true,
                            onCheckPressed: onDoubleCheckPressed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RegInputBox(
                            width: (horArea - 20) / 2,
                            labelText: '비밀번호',
                            hintText: '비밀번호를 입력해주세요',
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
                          RegInputBox(
                            width: (horArea - 20) / 2,
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
                  FilledButton(
                    onPressed: onRegisterPressed,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(330, 50),
                      backgroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
