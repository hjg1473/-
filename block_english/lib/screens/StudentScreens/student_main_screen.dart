import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentMainScreen extends ConsumerWidget {
  const StudentMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                top: 32.r,
                left: 44.r,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                icon: SvgPicture.asset(
                  'assets/buttons/round_back_button.svg',
                  width: 48.r,
                  height: 48.r,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 32.r,
              left: 342.r,
            ),
            child: Stack(
              alignment: const Alignment(0.3, 0),
              children: [
                SvgPicture.asset(
                  'assets/images/season_block.svg',
                  height: 45.r,
                  width: 128.r,
                ),
                Text(
                  seasonToString(ref.watch(statusProvider).season),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 115.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context)
                      .pushNamed('/stud_step_select_screen'),
                  icon: SvgPicture.asset(
                    'assets/cards/student_main_1.svg',
                    width: 230.r,
                    height: 207.r,
                  ),
                ),
                SizedBox(
                  width: 6.r,
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/setting_screen'),
                  icon: SvgPicture.asset(
                    'assets/cards/student_main_2.svg',
                    width: 205.r,
                    height: 207.r,
                  ),
                ),
                SizedBox(
                  width: 6.r,
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: SvgPicture.asset('assets/cards/student_main_3.svg',
                      width: 205.r, height: 207.r),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
