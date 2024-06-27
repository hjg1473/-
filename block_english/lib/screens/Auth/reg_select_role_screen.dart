import 'package:block_english/widgets/registration_button.dart';
import 'package:flutter/material.dart';

class RegSelectRoleScreen extends StatelessWidget {
  const RegSelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
            ),
            RegistrationWidget(
              icon: Icons.man,
              text: "교사/학부모",
              routeName: '/reg_super_screen',
            ),
            SizedBox(
              height: 40,
            ),
            RegistrationWidget(
              icon: Icons.child_care,
              text: "학생",
              routeName: '/reg_student_screen',
            ),
          ],
        ),
      ),
    );
  }
}
