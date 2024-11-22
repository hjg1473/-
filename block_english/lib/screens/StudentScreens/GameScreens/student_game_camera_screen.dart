import 'dart:async';
import 'package:block_english/screens/StudentScreens/GameScreens/student_game_end_screen.dart';
import 'package:block_english/screens/StudentScreens/GameScreens/student_game_result_screen.dart';
import 'package:block_english/utils/camera.dart';
import 'package:block_english/utils/game.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentGameCameraScreen extends ConsumerStatefulWidget {
  const StudentGameCameraScreen({
    super.key,
    required this.problemIndex,
  });

  final int problemIndex;

  @override
  ConsumerState<StudentGameCameraScreen> createState() =>
      _StudentGameCameraScreenState();
}

class _StudentGameCameraScreenState
    extends ConsumerState<StudentGameCameraScreen>
    with SingleTickerProviderStateMixin {
  late CameraController controller;
  late StreamController<bool> _btnController;
  int duration = 0;
  int remainingTime = 0;
  int totalDuration = 0;

  Future<void> _takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }

    if (_btnController.isClosed) return;
    _btnController.add(false);

    try {
      final xFile = await controller.takePicture();

      if (!mounted) return;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => StudentGameResultScreen(
          problemIndex: widget.problemIndex,
          xFile: xFile,
        ),
      ));
    } on Exception catch (e) {
      // TODO: error handling
      debugPrint('[CAMERA]: _takePicture $e');
    }
    if (_btnController.isClosed) return;
    _btnController.add(true);
  }

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      Camera.cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    controller.initialize().then((_) {
      controller.lockCaptureOrientation(DeviceOrientation.landscapeRight);
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
    _btnController = StreamController<bool>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.problemIndex % 5 == 0 &&
          !ref.watch(gameNotifierProvider).noMoreProblem) {
        ref.read(gameNotifierProvider.notifier).sendMoreProblemMeesage();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _btnController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(gameNotifierProvider).remainingTime == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const StudentGameEndScreen(),
          ),
          ModalRoute.withName('/stud_main_screen'),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (controller.value.isInitialized)
            Align(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: 1.sw / 1.sh,
                child: ClipRect(
                  child: Transform.scale(
                    scale: controller.value.aspectRatio,
                    child: Center(
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(),
                  ),
                ),
                SizedBox(
                  width: 1.sw,
                  height: 155.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: DashedLinePainter(),
                      ),
                      CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: DashedLinePainter(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(),
                  ),
                ),
              ],
            ),
          ),
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
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.circle,
                      size: 64.r,
                      color: const Color(0xFFD4D4D4),
                    ),
                    onPressed: () {
                      if (controller.value.isInitialized) {
                        _takePicture();
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12).r,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 10.r,
                              height: 29.r,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ).r,
                              ),
                            ),
                            IntrinsicWidth(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ).r,
                                height: 48.r,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8).r,
                                ),
                                child: Center(
                                  child: Text(
                                    ref
                                        .watch(gameNotifierProvider)
                                        .problems[widget.problemIndex]
                                        .value,
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '정답 블록의 정면을 정확히 촬영해주세요!',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 2),
                              blurRadius: 6,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 10.0, dashSpace = 5.0, startX = 0;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
