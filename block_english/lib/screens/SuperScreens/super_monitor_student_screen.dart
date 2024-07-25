import 'package:block_english/widgets/student_profile_card_widget.dart';
import 'package:flutter/material.dart';

class MonitorStudentScreen extends StatelessWidget {
  const MonitorStudentScreen({
    super.key,
    required this.studentName,
  });

  final String studentName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '학생 프로필',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: StudentProfileCard(
              name: studentName,
              age: "10세",
              isStudent: true,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text("Overall Score"),
          )
        ],
      ),
    );
  }
}
