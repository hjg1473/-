import 'package:block_english/models/model.dart';
import 'package:block_english/services/problem_service.dart';
import 'package:block_english/widgets/StudentWidget/problem_level_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentPracticeScreen extends ConsumerWidget {
  const StudentPracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: ref.watch(problemServiceProvider).getProblemInfo(),
          builder: (context, snapshot) {
            String error = '';
            int currentLevel = 0;
            int currentStep = 0;
            List<Level> levels = [];
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            snapshot.data!.fold(
              (failure) {
                error = failure.detail;
              },
              (problemInfoModel) {
                currentLevel = problemInfoModel.currentLevel;
                currentStep = problemInfoModel.currentStep;
                levels = problemInfoModel.levels;
              },
            );

            return error.isEmpty
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ProblemLevelWidget(
                          levelName: 'Level ${levels[index].levelName}');
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 20),
                    itemCount: levels.length,
                  )
                : const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
