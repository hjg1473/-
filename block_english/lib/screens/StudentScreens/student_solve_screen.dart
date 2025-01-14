import 'dart:math';

import 'package:block_english/models/ProblemModel/problems_model.dart';
import 'package:block_english/screens/StudentScreens/student_camera_screen.dart';
import 'package:block_english/services/problem_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class StudentSolveScreen extends ConsumerStatefulWidget {
  const StudentSolveScreen({
    super.key,
    required this.problemsModel,
    required this.level,
    required this.step,
    required this.totalNumber,
    required this.correctNumber,
  });

  final int level;
  final int step;
  final ProblemsModel problemsModel;
  final int totalNumber;
  final int correctNumber;

  @override
  ConsumerState<StudentSolveScreen> createState() => _StudentSolveScreenState();
}

class _StudentSolveScreenState extends ConsumerState<StudentSolveScreen> {
  late final ProblemEntry? currentProblem;

  @override
  void initState() {
    super.initState();
    currentProblem = widget.problemsModel.getProblem();
    if (currentProblem == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final response =
            await ref.watch(problemServiceProvider).postProblemEnd();

        response.fold(
          (failure) {
            debugPrint('[postProblemEnd] ${failure.detail}');
          },
          (response) {
            debugPrint('[postProblemEnd] ${response.data}');
          },
        );
      });
    }
    debugPrint('[totalNumber] ${widget.totalNumber}');
    debugPrint('[correctNumber] ${widget.correctNumber}');
  }

  getRandomLottiePath() {
    int rand = Random().nextInt(4);

    switch (rand) {
      case 0:
        return 'assets/lottie/motion_1.json';
      case 1:
        return 'assets/lottie/motion_4.json';
      case 2:
        return 'assets/lottie/motion_7.json';
      case 3:
        return 'assets/lottie/motion_10.json';
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
            if (currentProblem == null)
              Lottie.asset(
                'assets/lottie/motion_30.json',
                repeat: false,
              ),
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
                                  height: 36.r,
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
                                        widget.correctNumber)
                                    .r,
                                height: 24.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFA3C2),
                                  borderRadius: BorderRadius.circular(45).r,
                                ),
                              ),
                              Positioned(
                                left: ((220 / (widget.totalNumber)) *
                                            widget.correctNumber -
                                        30)
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
                  currentProblem != null
                      ? Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (currentProblem!.studyMode != StudyMode.retry)
                                Text(
                                  '아래 문장을 영어 블록을 사용해서 만들어봐!',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              SizedBox(
                                height: 14.r,
                              ),
                              SizedBox(
                                width: 630.r,
                                height: 180.r,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      height: 122.r,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8).r,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 6.r,
                                              offset: const Offset(0, 4),
                                              color: Colors.grey,
                                            ),
                                          ]),
                                      child: Text(
                                        currentProblem!.question,
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
                            ],
                          ),
                        )
                      : Positioned(
                          left: 95.r,
                          top: 41.r,
                          child: SizedBox(
                            width: 565.r,
                            height: 272.r,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 250.r,
                                  height: 272.r,
                                  child: Lottie.asset(
                                    'assets/lottie/motion_14.json',
                                  ),
                                ),
                                Align(
                                  alignment: const Alignment(0, -0.3),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/speechBallon.svg',
                                        width: 260.r,
                                        height: 140.r,
                                      ),
                                      SizedBox(
                                        width: 115.r,
                                        height: 91.r,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              width: 80.r,
                                              height: 34.r,
                                              decoration: BoxDecoration(
                                                color: Colors.pink[300],
                                                borderRadius:
                                                    BorderRadius.circular(40).r,
                                              ),
                                              child: Text(
                                                'step ${widget.step + 1}',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 115.r,
                                              height: 45.r,
                                              child: Text(
                                                'Clear!',
                                                style: TextStyle(
                                                  fontSize: 40.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  if (currentProblem == null)
                    Expanded(
                      child: SquareButton(
                        text: '나가기',
                        backgroundColor: const Color(0xFFB132FE),
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/stud_step_select_screen',
                              ModalRoute.withName('/stud_main_screen'));
                        },
                      ),
                    ),
                  Expanded(
                    child: SquareButton(
                      text: '계속하기',
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                      ),
                      onPressed: () {
                        if (currentProblem != null) {
                          // TODO: navigate to camera screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => StudentCameraScreen(
                                    level: widget.level,
                                    step: widget.step,
                                    problemsModel: widget.problemsModel,
                                    currentProblem: currentProblem!,
                                    totalNumber: widget.totalNumber,
                                    correctNumber: widget.correctNumber,
                                  )));
                        } else {
                          // TODO: load next step
                        }
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
