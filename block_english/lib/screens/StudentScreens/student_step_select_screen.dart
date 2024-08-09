import 'package:block_english/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentStepSelectScreen extends ConsumerStatefulWidget {
  const StudentStepSelectScreen({super.key});

  @override
  ConsumerState<StudentStepSelectScreen> createState() =>
      _StudentStepSelectScreenState();
}

class _StudentStepSelectScreenState
    extends ConsumerState<StudentStepSelectScreen> {
  int selectedLevel = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 32.r,
            left: 44.r,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              icon: SvgPicture.asset(
                'assets/buttons/labeled_back_button.svg',
                width: 133.r,
                height: 44.r,
              ),
            ),
          ),
          Positioned(
            top: 36.r,
            left: 324.r,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF93E54C),
                    borderRadius: BorderRadius.circular(40.0).w,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.r,
                    vertical: 10.r,
                  ),
                  child: Text(
                    levelList[selectedLevel],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.r,
                ),
                Text(
                  'Level ${selectedLevel + 1}',
                  style: TextStyle(
                    fontSize: 22.r,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Center(
            child: Text('data'),
          ),
        ],
      ),
    );
  }
}
