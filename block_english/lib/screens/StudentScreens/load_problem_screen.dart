import 'package:block_english/models/ProblemModel/problems_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/screens/StudentScreens/student_solve_screen.dart';
import 'package:block_english/services/problem_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadProblemScreen extends ConsumerStatefulWidget {
  const LoadProblemScreen({
    super.key,
    required this.season,
    required this.level,
    required this.step,
    required this.studyMode,
  });

  final int season;
  final int level;
  final int step;
  final StudyMode studyMode;

  @override
  ConsumerState<LoadProblemScreen> createState() => _LoadProblemScreenState();
}

class _LoadProblemScreenState extends ConsumerState<LoadProblemScreen> {
  loadProblems() async {
    late final Either<FailureModel, ProblemsModel> response;

    response = await ref
        .watch(problemServiceProvider)
        .getProblemPracticeSet(widget.season, widget.level, widget.step);

    response.fold((failure) {
      //TODO: error handling
      return null;
    }, (problemsModel) {
      //TODO: navigate to solve screen
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StudentSolveScreen(
                problemsModel: problemsModel,
                level: widget.level,
                step: widget.step,
                totalNumber: problemsModel.problems.length,
                correctNumber: 0,
              )));
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProblems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
