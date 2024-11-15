class GameStudentSolveModel {
  bool correct;

  GameStudentSolveModel.fromJson(Map<String, dynamic> json)
      : correct = json['correct'];
}
