import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/storage.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

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

      if (role != UserType.student.name &&
          role != UserType.parent.name &&
          role != UserType.teacher.name &&
          role != 'super') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('잘못된 권한입니다'),
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
        if (role == UserType.student.name) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/stud_mode_select_screen',
            (Route<dynamic> route) => false,
          );
        } else if (role == UserType.teacher.name ||
            role == UserType.parent.name) {
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 396.w,
                height: 1.sh,
                color: const Color(0xFFEAFDFF),
                child: Stack(
                  children: [
                    Positioned(
                      top: 69.r,
                      left: 98.16.r,
                      child: SvgPicture.asset(
                        'assets/images/LOGO.svg',
                        width: 241.7.r,
                        height: 39.r,
                      ),
                    ),
                    Positioned(
                      left: 63.r,
                      bottom: 55.r,
                      child: SizedBox(
                        width: 310.r,
                        child: Lottie.asset(
                          'assets/lottie/motion_13.json',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 416.w,
                height: 1.sh,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 38,
                        left: 42,
                        right: 64,
                      ).r,
                      child: SizedBox(
                        height: 269.r,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '로그인',
                                  style: TextStyle(
                                    fontSize: 22.sp,
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
                                      borderRadius: BorderRadius.circular(45).r,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ).r,
                                  ),
                                  child: Text(
                                    '회원가입',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(flex: 2),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '아이디',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF555555),
                                      ),
                                    ),
                                    usernameError
                                        ? Row(
                                            children: [
                                              SizedBox(width: 10.r),
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 12.r,
                                              ),
                                              SizedBox(width: 6.r),
                                              Text(
                                                usernameErrorMsg,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(width: 1),
                                  ],
                                ),
                                SizedBox(
                                  height: 6.r,
                                ),
                                TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ).r,
                                    hintText: '아이디를 입력해 주세요',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFFA3A3A3),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF0F0F0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8).w,
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      setState(() => username = value),
                                ),
                                SizedBox(height: 12.r),
                                Row(
                                  children: [
                                    Text(
                                      '비밀번호',
                                      style: TextStyle(
                                        fontSize: 16.r,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF555555),
                                      ),
                                    ),
                                    passwordError
                                        ? Row(
                                            children: [
                                              SizedBox(width: 10.r),
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 12.r,
                                              ),
                                              SizedBox(width: 6.r),
                                              Text(
                                                passwordErrorMsg,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(width: 1),
                                  ],
                                ),
                                SizedBox(
                                  height: 6.r,
                                ),
                                TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  obscureText: passwordObsecured,
                                  obscuringCharacter: '*',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ).r,
                                    hintText: '비밀번호를 입력해 주세요',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFFA3A3A3),
                                      fontSize: 16.sp,
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
                                      borderRadius: BorderRadius.circular(8).w,
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      setState(() => password = value),
                                ),
                                SizedBox(height: 10.r),
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
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFA3A3A3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ),
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
    );
  }
}
