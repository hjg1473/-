import 'package:block_english/screens/SuperScreens/super_monitor_group_screen.dart';
import 'package:block_english/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class GroupButton extends StatelessWidget {
  const GroupButton({
    super.key,
    required this.name,
    required this.id,
    required this.studentNum,
    this.detail = '',
    required this.onPressed,
  });

  final String name;
  final int id;
  final int studentNum;
  final String detail;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    double height = 72.r;
    double horizontalPadding = 16.r;
    double verticalPadding = 13.r;
    debugPrint(
        'name: $name, id: $id, studentNum: $studentNum, detail: $detail');
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: Size(334.r, height),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10).r,
        ),
      ),
      child: SizedBox(
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
            SizedBox(
              width: 16.r,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Row(
                    children: [
                      Text(
                        name,
                        style: textStyle16.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.r),
                      Icon(
                        Icons.person_rounded,
                        color: const Color(0xFF838383),
                        size: 16.r,
                      ),
                      Text(
                        ' $studentNum명',
                        style: textStyle11.copyWith(
                          color: const Color(0xFF9D9D9D),
                        ),
                      ),
                    ],
                  ),
                ),
                detail != ''
                    ? Text(
                        detail,
                        style: textStyle14.copyWith(
                          color: const Color(0xFF9D9D9D),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
