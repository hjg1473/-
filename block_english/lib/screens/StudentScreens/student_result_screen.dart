import 'dart:math';

import 'package:block_english/models/ProblemModel/problem_ocr_model.dart';
import 'package:block_english/models/ProblemModel/problems_model.dart';
import 'package:block_english/screens/StudentScreens/student_solve_screen.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class StudentResultScreen extends StatefulWidget {
  const StudentResultScreen({
    super.key,
    required this.level,
    required this.step,
    required this.problemsModel,
    required this.currentProblem,
    required this.problemOcrModel,
    required this.totalNumber,
    required this.correctNumber,
  });

  final int level;
  final int step;
  final ProblemsModel problemsModel;
  final ProblemEntry currentProblem;
  final ProblemOcrModel problemOcrModel;
  final int totalNumber;
  final int correctNumber;

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  late List<String> results;
  late int nextCorrectNumber;

  bool correct = true;

  getRandomLottiePath() {
    int rand = Random().nextInt(4);

    if (correct) {
      switch (rand) {
        case 0:
          return 'assets/lottie/motion_2.json';
        case 1:
          return 'assets/lottie/motion_5.json';
        case 2:
          return 'assets/lottie/motion_8.json';
        case 3:
          return 'assets/lottie/motion_11.json';
      }
    } else {
      switch (rand) {
        case 0:
          return 'assets/lottie/motion_3.json';
        case 1:
          return 'assets/lottie/motion_6.json';
        case 2:
          return 'assets/lottie/motion_9.json';
        case 3:
          return 'assets/lottie/motion_12.json';
      }
    }
  }

  @override
  void initState() {
    super.initState();

    nextCorrectNumber = widget.correctNumber;
    results = widget.problemOcrModel.userInput;

    correct = listEquals(
        widget.currentProblem.answer, widget.problemOcrModel.userInput);

    if (correct) {
      nextCorrectNumber++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1.sw,
        height: 1.sh,
        color: const Color(0xFFFFEEF4),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 44,
                vertical: 24,
              ).r,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20).r,
                            border: Border.all(
                              color: const Color(0xFFFF6699),
                            ),
                          ),
                          child: Row(
                            children: [
                              IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ).r,
                                  alignment: Alignment.center,
                                  height: 36.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6699),
                                    borderRadius: BorderRadius.circular(20).r,
                                  ),
                                  child: Text(
                                    'Level ${widget.level + 1}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ).r,
                                  height: 50.r,
                                  child: Center(
                                    child: Text(
                                      'Step ${widget.step + 1}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFFF6699),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 220.r,
                          height: 24.r,
                          child: Stack(
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
                                width: ((220 / (widget.totalNumber)) *
                                        nextCorrectNumber)
                                    .r,
                                height: 24.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFA3C2),
                                  borderRadius: BorderRadius.circular(45).r,
                                ),
                              ),
                              Positioned(
                                left: (((220 / (widget.totalNumber)) *
                                            nextCorrectNumber) -
                                        (61 / 2))
                                    .r,
                                child: SizedBox(
                                  width: 61.r,
                                  height: 32.r,
                                  child: SvgPicture.asset(
                                      'assets/progressbar/progress_block.svg'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 14.r,
                        ),
                        SizedBox(
                          width: 630.r,
                          height: 180.r,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 280.r,
                                height: 180.r,
                                child: Lottie.asset(
                                  getRandomLottiePath(),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 350.r,
                                height: 112.r,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8).r,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 6.r,
                                        offset: const Offset(0, 4),
                                        color: Colors.grey,
                                      ),
                                    ]),
                                child: Text(
                                  widget.currentProblem.question,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF7C7C7C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 731.r,
                          height: 64.r,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (String result in results)
                                  Padding(
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
                                        height: 32.r,
                                        decoration: BoxDecoration(
                                          color: correct
                                              ? blockColorCToColor(
                                                  widget.problemOcrModel
                                                          .blockColors[
                                                      results.indexOf(result)],
                                                )
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(4).r,
                                        ),
                                        child: Text(
                                          result,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: SquareButton(
                      text: '계속하기',
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) {
                            ProblemsModel nextProblemsModel =
                                widget.problemsModel;

                            if (!correct) {
                              nextProblemsModel
                                  .addProblem(widget.currentProblem);
                            }

                            return StudentSolveScreen(
                              problemsModel: nextProblemsModel,
                              level: widget.level,
                              step: widget.step,
                              totalNumber: widget.totalNumber,
                              correctNumber: nextCorrectNumber,
                            );
                          }),
                          ModalRoute.withName('/stud_main_screen'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
