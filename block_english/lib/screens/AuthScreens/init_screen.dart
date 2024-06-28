import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/round_corner_route_button.dart';
import 'package:flutter/material.dart';

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.abc,
              size: 300,
            ),
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: RoundCornerRouteButton(
                text: "로그인",
                routeName: '/login_screen',
                width: 313,
                height: 45,
                type: ButtonType.filled,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: RoundCornerRouteButton(
                text: "회원가입",
                routeName: '/reg_select_role_screen',
                width: 313,
                height: 45,
                type: ButtonType.outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
