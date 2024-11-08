import 'package:block_english/utils/color.dart';
import 'package:block_english/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class StudentInGroupButton extends StatelessWidget {
  const StudentInGroupButton({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onPressed,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final selectedBorderColor = primaryPurple[300];
    final selectedBackgroundColor = primaryPurple[200];
    const selectedTextColor = Colors.white;
    const unselectedBorderColor = Colors.transparent;
    const unselectedBackgroundColor = Colors.white;
    const unselectedTextColor = Colors.black;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor:
            isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
        minimumSize: Size(140.r, 52.r),
        padding: EdgeInsets.only(left: 8.r),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected ? selectedBorderColor! : unselectedBorderColor,
            width: 2.r,
          ),
          borderRadius: BorderRadius.circular(8).r,
        ),
      ),
      child: SizedBox(
        width: 132.r,
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
            SizedBox(width: 12.r),
            Text(
              name,
              style: textStyle16.copyWith(
                color: isSelected ? selectedTextColor : unselectedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
