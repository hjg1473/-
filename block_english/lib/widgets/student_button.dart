import 'package:block_english/screens/SuperScreens/super_monitor_student_screen.dart';
import 'package:flutter/material.dart';

class StudentButton extends StatelessWidget {
  const StudentButton({
    super.key,
    required this.name,
    this.groupId = -1,
    required this.studentId,
  });

  final int studentId;
  final String name;
  final int groupId;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonitorStudentScreen(
              studentName: name,
              studentId: studentId,
            ),
          ),
        );
      },
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFEAEAEA),
        minimumSize: const Size(330, 80),
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                name[0],
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
