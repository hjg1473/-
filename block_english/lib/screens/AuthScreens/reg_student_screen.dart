import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/round_corner_route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:block_english/services/auth_service.dart';

class RegStudentScreen extends StatefulWidget {
  const RegStudentScreen({super.key});

  @override
  State<RegStudentScreen> createState() => _RegStudentScreenState();
}

class _RegStudentScreenState extends State<RegStudentScreen> {
  final formkey = GlobalKey<FormState>();

  String name = '';
  String username = '';
  String password = '';
  int grade = -1;

  onRegisterPressed() async {
    if (!formkey.currentState!.validate() || grade == -1) {
      return;
    }

    int statusCode = await AuthService.postAuthRegister(
        name, username, password, grade, "student");

    if (statusCode != 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입에 실패했습니다. 다시 시도해 주세요. statusCode : $statusCode'),
          ),
        );
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/init',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formkey,
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
                  onChanged: (value) => setState(() => name = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                height: 30,
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
              const SizedBox(
                height: 30,
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
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: CustomDropdown(
                  decoration: const CustomDropdownDecoration(
                    closedFillColor: Color.fromRGBO(237, 231, 246, 1),
                    expandedFillColor: Color.fromRGBO(237, 231, 246, 1),
                  ),
                  hintText: "학년을 선택해주세요",
                  items: gradelist,
                  onChanged: (value) =>
                      setState(() => grade = gradelist.indexOf(value!)),
                ),
              ),
              const SizedBox(
                height: 250,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const RoundCornerRouteButton(
                      text: "취소",
                      routeName: '/reg_select_role_screen',
                      width: 150,
                      height: 45,
                      type: ButtonType.outlined,
                      cancel: true,
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: onRegisterPressed,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(150, 45)),
                      child: const Text("회원가입"),
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
