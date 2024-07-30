import 'package:block_english/widgets/registration_button.dart';
import 'package:flutter/material.dart';

class RegSelectRoleScreen extends StatelessWidget {
  const RegSelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: const Text(
                        '로그인',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.minPositive, 40),
                        backgroundColor: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        const Text(
                          '나는 어떤 사용자인가요?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '본인의 신분에 맞게 선택해주세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    //TODO: 정렬 맞추기
                    const SizedBox(width: 100),
                  ],
                ),
                const Spacer(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RegistrationWidget(
                      icon: Icons.supervisor_account,
                      label: '관리자',
                      text: '교사, 학부모는 선택해주세요',
                      routeName: '/reg_super_screen',
                    ),
                    SizedBox(width: 60),
                    RegistrationWidget(
                      icon: Icons.school,
                      label: '학습자',
                      text: '학생들은 선택해주세요',
                      routeName: '/reg_student_screen',
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
