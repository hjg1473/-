import 'package:block_english/screens/SuperScreens/super_monitor_student_screen.dart';
import 'package:block_english/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class StudentButton extends StatelessWidget {
  const StudentButton({
    super.key,
    required this.name,
    this.groupId = -1,
    required this.studentId,
    this.groupName = '',
  });

  final int studentId;
  final String name;
  final int groupId;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    double height = 72.r;
    double padding = 16.r;

    return FilledButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonitorStudentScreen(
              studentName: name,
              studentId: studentId,
              groupName: groupName,
              initialPage: 1,
            ),
          ),
        );
      },
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: Size(334.r, height),
        padding: EdgeInsets.all(padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10).r,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Lottie.asset(
              'assets/lottie/motion_19.json',
              width: 40.r,
              height: 40.r,
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
                style: textStyle16.copyWith(color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
