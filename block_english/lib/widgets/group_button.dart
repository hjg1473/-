import 'package:block_english/screens/SuperScreens/super_monitor_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupButton extends StatelessWidget {
  const GroupButton({
    super.key,
    required this.name,
    required this.id,
    required this.studentNum,
    this.detail = '',
  });

  final String name;
  final int id;
  final int studentNum;
  final String detail;

  @override
  Widget build(BuildContext context) {
    double height = 72;
    double padding = 12;
    double area = height - padding * 2;

    return FilledButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MonitorGroupScreen(
                      groupName: name,
                      detailText: detail,
                      groupId: id,
                    )));
      },
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFEAEAEA),
        minimumSize: Size(334, height),
        padding: EdgeInsets.all(padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10).r,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: area,
            width: area,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(5).r,
            ),
            child: Center(
              child: Text(
                id.toString(),
                style: const TextStyle(
                  color: Color(0xFFC2C2C2),
                  fontSize: 30,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 15.r,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8.r),
                  Icon(Icons.person_rounded,
                      color: const Color(0xFF838383), size: 13.r),
                  Text(' $studentNum명',
                      style: TextStyle(
                        color: const Color(0xFF9D9D9D),
                        fontSize: 12.sp,
                      )),
                ],
              ),
              detail != ''
                  ? Text(
                      detail,
                      style: TextStyle(
                        color: const Color(0xFF9D9D9D),
                        fontSize: 13.sp,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFA0A0A0)),
        ],
      ),
    );
  }
}
