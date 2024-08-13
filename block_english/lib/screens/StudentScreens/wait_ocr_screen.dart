import 'package:block_english/models/ProblemModel/problems_model.dart';
import 'package:block_english/screens/StudentScreens/student_result_screen.dart';
import 'package:block_english/services/problem_service.dart';
import 'package:block_english/utils/process_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class WaitOcrScreen extends ConsumerStatefulWidget {
  const WaitOcrScreen({
    super.key,
    required this.level,
    required this.step,
    required this.problemsModel,
    required this.currentProblem,
    required this.totalNumber,
    required this.correctNumber,
    required this.xFile,
  });

  final int level;
  final int step;
  final ProblemsModel problemsModel;
  final ProblemEntry currentProblem;
  final int totalNumber;
  final int correctNumber;
  final XFile xFile;

  @override
  ConsumerState<WaitOcrScreen> createState() => _WaitOcrScreenState();
}

class _WaitOcrScreenState extends ConsumerState<WaitOcrScreen> {
  waitOcr() async {
    final png = await ProcessImage.cropImage(widget.xFile);

    final result = await ref
        .watch(problemServiceProvider)
        .postProblemOCR(png, widget.currentProblem.id);

    result.fold(
      (failure) {
        // TODO: error handling
      },
      (problemOcrModel) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentResultScreen(
              level: widget.level,
              step: widget.step,
              problemsModel: widget.problemsModel,
              currentProblem: widget.currentProblem,
              problemOcrModel: problemOcrModel,
              totalNumber: widget.totalNumber,
              correctNumber: widget.correctNumber,
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      waitOcr();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Lottie.asset('assets/lottie/motion_29.json'),
    );
  }
}
