import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/device_scale.dart';
import 'package:block_english/utils/storage.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  final formkey = GlobalKey<FormState>();

  String username = '';
  String password = '';

  bool passwordObsecured = true;

  onLoginPressed() async {
    if (!formkey.currentState!.validate()) {
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
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 396.w,
                  height: 1.sh,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 416.w,
                  height: 1.sh,
                  child: Form(
                    key: formkey,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 38.h,
                            left: 42.w,
                            right: 42.w,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        borderRadius: BorderRadius.circular(45),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 12.h,
                                      ),
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
                              SizedBox(
                                height: 18.h,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '아이디',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF555555),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6.h,
                                  ),
                                  TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      hintText: '전화번호 또는 이메일을 입력해 주세요',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFFA3A3A3),
                                        fontSize: 16.sp,
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '아이디를 입력해 주세요';
                                      }
                                      if (value.length < 6) {
                                        return '아이디가 너무 짧습니다';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '비밀번호',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF555555),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6.h,
                                  ),
                                  TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]'),
                                      ),
                                    ],
                                    obscureText: passwordObsecured,
                                    obscuringCharacter: '*',
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      hintText: '비밀번호를 입력해주세요',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFFA3A3A3),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          passwordObsecured
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_outlined,
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '비밀번호를 입력해주세요';
                                      }
                                      if (value.length < 8) {
                                        return '비밀번호가 너무 짧습니다';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
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
                        ),
                        const Spacer(),
                        SquareButton(
                          text: '로그인',
                          onPressed: onLoginPressed,
                        ),
                      ],
                    ),
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
