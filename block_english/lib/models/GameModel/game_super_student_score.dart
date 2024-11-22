import 'package:block_english/utils/game.dart';

class GameSuperStudentScore {
  List<Pair<String, int>> studentList = [];

  GameSuperStudentScore.fromJson(Map<String, dynamic> json) {
    studentList = json.entries
        .where((entry) => entry.value is int)
        .map((entry) => Pair(entry.key, entry.value as int))
        .toList();
  }
}
