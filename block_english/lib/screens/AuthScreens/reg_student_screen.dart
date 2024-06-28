import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/round_corner_route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegStudentScreen extends StatefulWidget {
  const RegStudentScreen({super.key});

  @override
  State<RegStudentScreen> createState() => _RegStudentScreenState();
}

class _RegStudentScreenState extends State<RegStudentScreen> {
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                child: Text(
                  "학생",
                  style: TextStyle(
                    color: Color.fromRGBO(74, 20, 140, 1),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextFormField(
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Color.fromRGBO(237, 231, 246, 1),
                    border: UnderlineInputBorder(),
                    labelText: '이름',
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "10자 이내",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
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
              const SizedBox(
                height: 10,
              ),
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
              const SizedBox(
                height: 250,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RoundCornerRouteButton(
                      text: "취소",
                      routeName: '/reg_select_role_screen',
                      width: 150,
                      height: 45,
                      type: ButtonType.outlined,
                      cancel: true,
                    ),
                    RoundCornerRouteButton(
                      text: "회원가입",
                      routeName: '/reg_select_role_screen',
                      width: 150,
                      height: 45,
                      type: ButtonType.filled,
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
