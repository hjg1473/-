class ProblemPracticeInfoModel {
  List<Level> levels;

  ProblemPracticeInfoModel({
    required this.levels,
  });

  static ProblemPracticeInfoModel fromJson(Map<String, dynamic> json) {
    var levelsFromJson = json['levels'] as List;
    List<Level> levelList =
        levelsFromJson.map((levelJson) => Level.fromJson(levelJson)).toList();

    return ProblemPracticeInfoModel(
      levels: levelList,
    );
  }
}

class Level {
  int levelName;
  List<int> steps;

  Level({
    required this.levelName,
    required this.steps,
  });

  static Level fromJson(Map<String, dynamic> json) {
    return Level(
      levelName: json['level_name'],
      steps: List<int>.from(json['steps']),
    );
  }
}
