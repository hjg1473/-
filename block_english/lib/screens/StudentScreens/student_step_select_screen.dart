import 'package:block_english/models/ProblemModel/problem_info_model.dart';
import 'package:block_english/services/problem_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/status.dart';
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
  int numberOfLevels = 0;
  int numberOfSteps = 0;

  bool problemFetched = false;

  late final ProblemPracticeInfoModel _problems;

  getProblemPracticeInfo() async {
    final result = await ref
        .watch(problemServiceProvider)
        .getProblemPracticeInfo(seasonToInt(ref.watch(statusProvider).season));

    result.fold((failure) {
      //TODO: error handling (exit)
    }, (problemInfo) {
      setState(() {
        _problems = problemInfo;
        numberOfLevels = _problems.levels.length;
        numberOfSteps = _problems.levels[0].steps.length;
        problemFetched = true;
      });
    });
  }

  bool isLevelLocked(int level) {
    return (ref
            .watch(statusProvider)
            .releaseStatus[ref.watch(statusProvider).season]!
            .currentLevel <=
        level);
  }

  bool isStepLocked(int step) {
    return (ref
            .watch(statusProvider)
            .releaseStatus[ref.watch(statusProvider).season]!
            .currentStep <=
        step);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getProblemPracticeInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBDA),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ).r,
                  child: Text(
                    levellist[selectedLevel],
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

          // Body
          Center(
            child: Container(
              alignment: Alignment.center,
              width: 683.r,
              height: 78.r,
              child: problemFetched
                  ? ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return ClipOval(
                          child: Container(
                            alignment: Alignment.center,
                            width: 78.r,
                            height: 78.r,
                            color: isStepLocked(index)
                                ? const Color(0xFF999999)
                                : const Color(0xFFB132FE),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                index != numberOfSteps
                                    ? Text(
                                        'STEP ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        '오답',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                if (isStepLocked(index))
                                  Center(
                                    child: Icon(
                                      Icons.lock,
                                      size: 28.r,
                                      color: const Color(0xFFFFFBDA),
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          width: 43.r,
                        );
                      },
                      itemCount: numberOfSteps + 1,
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),

          // Bottom level button
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                for (int index = 0; index < numberOfLevels; index++)
                  GestureDetector(
                    onTap: () {
                      if (isLevelLocked(index)) {
                        // TODO: 자물쇠 흔들리는 애니메이션이라든지
                        return;
                      }
                      setState(() {
                        selectedLevel = index;
                        numberOfSteps = _problems.levels[index].steps.length;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 1.sw / numberOfLevels,
                      height: 68.r,
                      decoration: BoxDecoration(
                        color: isLevelLocked(index)
                            ? const Color(0xFF999999)
                            : index == selectedLevel
                                ? const Color(0xFFB132FE)
                                : const Color(0xFF2C2C2C),
                        border: Border.symmetric(
                          vertical: BorderSide(
                            width: 1,
                            color: const Color(0x00ffffff).withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              levellist[index],
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isLevelLocked(index))
                            Center(
                              child: Icon(
                                Icons.lock,
                                size: 28.r,
                                color: const Color(0xFFFFFBDA),
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
