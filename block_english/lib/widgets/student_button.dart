import 'package:block_english/screens/SuperScreens/super_monitor_student_screen.dart';
import 'package:block_english/utils/colors.dart';
import 'package:flutter/material.dart';

class StudentButton extends StatelessWidget {
  const StudentButton({
    super.key,
    required this.name,
    this.groupId = -1,
  });

  final String name;
  final int groupId;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MonitorStudentScreen(studentName: name)));
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
                style: const TextStyle(
                  color: lightSurface,
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
