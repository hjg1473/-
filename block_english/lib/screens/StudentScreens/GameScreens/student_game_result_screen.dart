import 'dart:async';
import 'package:block_english/models/ProblemModel/problems_model.dart';
import 'package:block_english/screens/StudentScreens/wait_ocr_screen.dart';
import 'package:block_english/utils/camera.dart';
import 'package:block_english/utils/game.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentGameResultScreen extends ConsumerStatefulWidget {
  const StudentGameResultScreen({
    super.key,
    required this.problemIndex,
    required this.xFile,
  });

  final int problemIndex;
  final XFile xFile;

  @override
  ConsumerState<StudentGameResultScreen> createState() =>
      _StudentGameResultScreenState();
}

class _StudentGameResultScreenState
    extends ConsumerState<StudentGameResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int duration = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 44,
              right: 44,
              top: 24,
              bottom: 16,
            ).r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                    alignment: Alignment.center,
                    width: 60.r,
                    height: 48.r,
                    child: Text(
                      '${widget.problemIndex + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 220.r,
                    height: 24.r,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 220.r,
                              height: 24.r,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(45).r,
                              ),
                            ),
                            Container(
                              width: (220 * _animationController.value).r,
                              height: 24.r,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA3C2),
                                borderRadius: BorderRadius.circular(45).r,
                              ),
                            ),
                            Positioned(
                              left: ((220 * _animationController.value) -
                                      (61 / 2))
                                  .r,
                              child: SizedBox(
                                width: 61.r,
                                height: 32.r,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/progressbar/progress_block.svg',
                                    ),
                                    Text(
                                      '시간',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Align(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ).r,
                    child: IntrinsicWidth(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ).r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6699),
                          borderRadius: BorderRadius.circular(4).r,
                        ),
                        child: Text(
                          'asdfdsa',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
