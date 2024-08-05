import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/size_config.dart';
import 'package:block_english/utils/storage.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  String username = '';
  String password = '';

  bool usernameError = false;
  bool passwordError = false;

  String usernameErrorMsg = '';
  String passwordErrorMsg = '';

  bool passwordObsecured = true;

  validateUsername(String value) {
    if (value.isEmpty) {
      usernameErrorMsg = '아이디를 입력해 주세요';
      return true;
    }
    if (value.length < 6) {
      usernameErrorMsg = '아이디가 너무 짧습니다';
      return true;
    }
    return false;
  }

  validatePassword(String value) {
    if (value.isEmpty) {
      passwordErrorMsg = '비밀번호를 입력해 주세요';
      return true;
    }
    if (value.length < 8) {
      passwordErrorMsg = '비밀번호가 너무 짧습니다';
      return true;
    }
    return false;
  }

  onLoginPressed() async {
    setState(() {
      usernameError = validateUsername(username);
      passwordError = validatePassword(password);
    });

    if (usernameError || passwordError) {
      return;
    }

    final result =
        await ref.watch(authServiceProvider).postAuthToken(username, password);

    result.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${failure.statusCode}: ${failure.detail}'),
          ),
        );
      }
    }, (loginResponseModel) async {
      var role = loginResponseModel.role;

      if (role != 'student' && role != 'super') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인 다시해'),
            ),
          );
        }
      }

      await ref
          .watch(secureStorageProvider)
          .saveAccessToken(loginResponseModel.accessToken);
      await ref
          .watch(secureStorageProvider)
          .saveRefreshToken(loginResponseModel.refreshToken);

      if (mounted) {
        if (role == 'student') {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/stud_mode_select_screen',
            (Route<dynamic> route) => false,
          );
        } else if (role == 'super') {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/super_main_screen',
            (Route<dynamic> route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 396 * SizeConfig.scaleWidth,
                  height: SizeConfig.fullHeight,
                  color: Colors.lightBlue[100],
                ),
                SizedBox(
                  width: 416 * SizeConfig.scaleWidth,
                  height: SizeConfig.fullHeight,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 38 * SizeConfig.scaleHeight,
                          left: 42 * SizeConfig.scaleWidth,
                          right: 42 * SizeConfig.scaleWidth,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '로그인',
                                  style: TextStyle(
                                    fontSize: 22 * SizeConfig.scales,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed('/reg_select_role_screen');
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFB132FE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(45),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20 * SizeConfig.scales,
                                      vertical: 12 * SizeConfig.scales,
                                    ),
                                  ),
                                  child: Text(
                                    '회원가입',
                                    style: TextStyle(
                                      fontSize: 16 * SizeConfig.scales,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 18 * SizeConfig.scales,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '아이디',
                                      style: TextStyle(
                                        fontSize: 16 * SizeConfig.scales,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF555555),
                                      ),
                                    ),
                                    usernameError
                                        ? Row(
                                            children: [
                                              SizedBox(
                                                  width:
                                                      10 * SizeConfig.scales),
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 12 * SizeConfig.scales,
                                              ),
                                              SizedBox(
                                                  width: 6 * SizeConfig.scales),
                                              Text(
                                                usernameErrorMsg,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize:
                                                      11 * SizeConfig.scales,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(width: 1),
                                  ],
                                ),
                                SizedBox(
                                  height: 6 * SizeConfig.scales,
                                ),
                                TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16 * SizeConfig.scales,
                                      vertical: 12 * SizeConfig.scales,
                                    ),
                                    hintText: '아이디를 입력해 주세요',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFFA3A3A3),
                                      fontSize: 16 * SizeConfig.scales,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF0F0F0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      setState(() => username = value),
                                ),
                              ],
                            ),
                            SizedBox(height: 12 * SizeConfig.scales),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '비밀번호',
                                      style: TextStyle(
                                        fontSize: 16 * SizeConfig.scales,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF555555),
                                      ),
                                    ),
                                    passwordError
                                        ? Row(
                                            children: [
                                              SizedBox(
                                                  width:
                                                      10 * SizeConfig.scales),
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 12 * SizeConfig.scales,
                                              ),
                                              SizedBox(
                                                  width: 6 * SizeConfig.scales),
                                              Text(
                                                passwordErrorMsg,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize:
                                                      11 * SizeConfig.scales,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(width: 1),
                                  ],
                                ),
                                SizedBox(
                                  height: 6 * SizeConfig.scales,
                                ),
                                TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  obscureText: passwordObsecured,
                                  obscuringCharacter: '*',
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16 * SizeConfig.scales,
                                      vertical: 12 * SizeConfig.scales,
                                    ),
                                    hintText: '비밀번호를 입력해 주세요',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFFA3A3A3),
                                      fontSize: 16 * SizeConfig.scales,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        passwordObsecured
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_rounded,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          passwordObsecured =
                                              !passwordObsecured;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF0F0F0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      setState(() => password = value),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10 * SizeConfig.scales,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    '비밀번호 찾기',
                                    style: TextStyle(
                                      fontSize: 14 * SizeConfig.scales,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFA3A3A3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SquareButton(
                        text: '로그인',
                        onPressed: onLoginPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
