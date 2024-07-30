import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  final formkey = GlobalKey<FormState>();

  String username = '';
  String password = '';

  onLoginPressed() async {
    if (!formkey.currentState!.validate()) {
      return;
    }

    final result =
        await ref.watch(authServiceProvider).postAuthToken(username, password);

    result.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 다시해'),
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
            '/stud_main_screen',
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
    Size screenSize = MediaQuery.of(context).size;
    var horArea =
        screenSize.width - MediaQuery.of(context).viewPadding.horizontal;
    var verArea =
        screenSize.height - MediaQuery.of(context).viewPadding.vertical;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: screenSize.width / 2 - 10,
            height: screenSize.height,
            color: Colors.grey[200],
          ),
          SizedBox(
            width: screenSize.width / 2 + 10,
            height: screenSize.height,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horArea == screenSize.width ? 20 : 0,
                  30,
                  horArea == screenSize.width ? 20 : 0,
                  verArea == screenSize.height ? 30 : 10,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formkey,
                    child: SizedBox(
                      height: screenSize.height - 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('로그인',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  )),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed('/reg_select_role_screen');
                                },
                                style: FilledButton.styleFrom(
                                  minimumSize:
                                      const Size(double.minPositive, 40),
                                  backgroundColor: Colors.grey[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text(
                                  '회원가입',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '아이디',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              hintText: '전화번호 또는 이메일을 입력해주세요',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) =>
                                setState(() => username = value),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '아이디를 입력해주세요';
                              }
                              if (value.length < 6) {
                                return '아이디가 너무 짧습니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '비밀번호',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                            ],
                            obscureText: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              hintText: '비밀번호를 입력해주세요',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
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
                          Row(
                            children: [
                              const Spacer(),
                              SizedBox(
                                height: 35,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(),
                                  child: Text(
                                    '비밀번호 찾기',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[500]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          FilledButton(
                            onPressed: onLoginPressed,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.grey[500],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '로그인',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
