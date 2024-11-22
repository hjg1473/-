import 'package:block_english/screens/StudentScreens/GameScreens/student_game_camera_screen.dart';
import 'package:block_english/screens/StudentScreens/GameScreens/student_game_end_screen.dart';
import 'package:block_english/services/game_service.dart';
import 'package:block_english/utils/game.dart';
import 'package:block_english/utils/process_image.dart';
import 'package:block_english/utils/status.dart';
import 'package:block_english/widgets/square_button.dart';
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
    extends ConsumerState<StudentGameResultScreen> {
  int duration = 0;

  String ocrResult = "";

  waitOcr() async {
    final png = await ProcessImage.cropImage(widget.xFile);

    final result = await ref.watch(gameServiceProvider).postGameSolve(
          ref.watch(gameNotifierProvider).pinCode,
          ref.watch(statusProvider).username,
          widget.problemIndex,
          png,
        );

    result.fold(
      (failure) {
        // TODO: error handling
      },
      (problemOcrModel) {
        setState(() {
          ocrResult = problemOcrModel.ocrResult;
        });
        debugPrint("[GAME OCRRESULT] $ocrResult");
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      waitOcr();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(gameNotifierProvider).remainingTime == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const StudentGameEndScreen(),
        ));
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFEC),
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
                          width: (220 *
                                  (1 -
                                      ref
                                              .watch(gameNotifierProvider)
                                              .remainingTime /
                                          ref
                                              .watch(gameNotifierProvider)
                                              .duration))
                              .r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA3C2),
                            borderRadius: BorderRadius.circular(45).r,
                          ),
                        ),
                        Positioned(
                          left: (220 *
                                      (1 -
                                          ref
                                                  .watch(gameNotifierProvider)
                                                  .remainingTime /
                                              ref
                                                  .watch(gameNotifierProvider)
                                                  .duration) -
                                  30)
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
                                  "${ref.watch(gameNotifierProvider).remainingTime ~/ 60}:${(ref.watch(gameNotifierProvider).remainingTime % 60).toString().padLeft(2, '0')}",
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
                    ),
                  ),
                ),
                Align(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ).r,
                    child: IntrinsicWidth(
                      child: ocrResult == ""
                          ? const CircularProgressIndicator()
                          : Container(
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
                                ocrResult,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: SquareButton(
              text: '제출하기',
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: () {
                if (widget.problemIndex ==
                    ref.watch(gameNotifierProvider).problems.length) {
                  ref.watch(gameNotifierProvider.notifier).stopCountdown();
                }

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StudentGameCameraScreen(
                    problemIndex: 1 + widget.problemIndex,
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
