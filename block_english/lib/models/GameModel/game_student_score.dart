import 'package:block_english/utils/game.dart';

class GameStudentScore {
  List<Pair<String, int>> studentList = [];

  GameStudentScore.fromJson(Map<String, dynamic> json) {
    final studList = json as Map<String, int>;
    List<Pair<String, int>> studentList =
        studList.entries.map((entry) => Pair(entry.key, entry.value)).toList();
  }
}
