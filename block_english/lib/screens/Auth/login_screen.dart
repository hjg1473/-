import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/round_corner_route_button.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Column(
          children: [
            Icon(
              Icons.abc,
              size: 300,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '아이디',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '비밀번호',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: RoundCornerRouteButton(
                text: "로그인",
                routeName: '/init',
                width: 313,
                height: 45,
                type: ButtonType.filled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
