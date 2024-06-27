import 'package:block_english/widgets/registration_button.dart';
import 'package:flutter/material.dart';

class RegSelectRoleScreen extends StatelessWidget {
  const RegSelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            const RegistrationWidget(
              icon: Icons.man,
              text: "교사/학부모",
              routeName: '/reg_super',
            ),
            const SizedBox(
              height: 30,
            ),
            const RegistrationWidget(
              icon: Icons.child_care,
              text: "학생",
              routeName: '/reg_student',
            ),
            const SizedBox(
              height: 45,
            ),
            SizedBox(
              height: 45,
              width: 150,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("취소"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
