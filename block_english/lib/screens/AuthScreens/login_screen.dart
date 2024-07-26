import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formkey,
            child: Column(
              children: [
                const Icon(
                  Icons.abc,
                  size: 300,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromRGBO(237, 231, 246, 1),
                          border: UnderlineInputBorder(),
                          labelText: '아이디',
                        ),
                        onChanged: (value) => setState(() => username = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '아이디를 입력해주세요';
                          }
                          if (value.length < 6) {
                            return '아이디가 너무 짧습니다';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        "영문/숫자 조합, 6자 이상",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                        ],
                        obscureText: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromRGBO(237, 231, 246, 1),
                          border: UnderlineInputBorder(),
                          labelText: '비밀번호',
                        ),
                        onChanged: (value) => setState(() => password = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          if (value.length < 8) {
                            return '비밀번호가 너무 짧습니다';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        "영문/숫자 조합, 8자 이상",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 15.0),
                  child: FilledButton(
                    onPressed: onLoginPressed,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(313, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
