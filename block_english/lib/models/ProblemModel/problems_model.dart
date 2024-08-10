import 'package:block_english/utils/constants.dart';

class ProblemsModel {
  List<ProblemEntry> problems;

  ProblemEntry? getProblem() {
    if (problems.isEmpty) return null;
    return problems.removeAt(0);
  }

  ProblemsModel({required this.problems});

  static ProblemsModel fromJson(
      Map<String, dynamic> json, StudyMode studyMode) {
    final problemList = json['problems'] as List;

    List<ProblemEntry> entries = [];
    for (var problem in problemList) {
      if (studyMode == StudyMode.game) {
        entries.add(ProblemEntry(
          id: problem['id'],
          question: problem['koreaProblem'],
          answer: problem['englishProblem'],
          studyMode: studyMode,
        ));
      } else {
        final colors = problem['blockColors'] as List;
        entries.add(ProblemEntry(
          id: problem['id'],
          question: problem['koreaProblem'],
          answer: problem['englishProblem'],
          studyMode: studyMode,
          blockColors:
              colors.map((color) => stringToBlockColor(color)).toList(),
        ));
      }
    }

    return ProblemsModel(problems: entries);
  }
}

class ProblemEntry {
  int id;
  String question;
  String answer;
  StudyMode studyMode;
  List<BlockColor> blockColors;

  ProblemEntry({
    required this.id,
    required this.question,
    required this.answer,
    required this.studyMode,
    this.blockColors = const [],
  });
}
