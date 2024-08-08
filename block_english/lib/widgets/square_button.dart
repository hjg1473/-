import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SquareButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final Icon? icon;

  const SquareButton({
    super.key,
    required this.text,
    this.backgroundColor = Colors.black,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68.r,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          disabledBackgroundColor: const Color(0xFF727272),
          backgroundColor: backgroundColor,
          shape: const BeveledRectangleBorder(),
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 10).r,
                child: icon!,
              ),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
