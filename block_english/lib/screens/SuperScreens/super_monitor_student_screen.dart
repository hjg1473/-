import 'package:block_english/widgets/student_profile_card_widget.dart';
import 'package:flutter/material.dart';

class MonitorStudentScreen extends StatelessWidget {
  const MonitorStudentScreen({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  final String studentName;
  final int studentId;

  onDeletePressed() async {}

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            StudentProfileCard(
              name: studentName,
              age: "10세",
              isStudent: true,
            ),
            const SizedBox(
              height: 30,
            ),
            const Text("Overall Score"),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: onDeletePressed,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ),
                      ),
                      backgroundColor: Colors.black),
                  child: const Text(
                    '학습자 삭제하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
