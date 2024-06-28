import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/round_corner_route_button.dart';
import 'package:flutter/material.dart';

class RegStudentScreen extends StatefulWidget {
  const RegStudentScreen({super.key});

  @override
  State<RegStudentScreen> createState() => _RegStudentScreenState();
}

class _RegStudentScreenState extends State<RegStudentScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
          ),
          Padding(
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
          Divider(
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(237, 231, 246, 1),
                border: UnderlineInputBorder(),
                labelText: '이름',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "10자 이내",
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(237, 231, 246, 1),
                border: UnderlineInputBorder(),
                labelText: '아이디',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "영문/숫자 조합, 15자 이내",
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(237, 231, 246, 1),
                border: UnderlineInputBorder(),
                labelText: '비밀번호',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "영문/숫자/특수문자 조합, 10자 이상",
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(
            height: 250,
          ),
          Padding(
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
    );
  }
}
