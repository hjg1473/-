class ProblemInfoModel {
  int currentLevel;
  int currentStep;
  List<Level> levels;

  ProblemInfoModel({
    required this.currentLevel,
    required this.currentStep,
    required this.levels,
  });

  static ProblemInfoModel fromJson(Map<String, dynamic> json) {
    var levelsFromJson = json['levels'] as List;
    List<Level> levelList =
        levelsFromJson.map((levelJson) => Level.fromJson(levelJson)).toList();

    return ProblemInfoModel(
      currentLevel: json['current_level'],
      currentStep: json['current_step'],
      levels: levelList,
    );
  }
}

class Level {
  String levelName;
  List<String> steps;

  Level({
    required this.levelName,
    required this.steps,
  });

  // JSON 데이터를 객체로 변환하는 static 메서드
  static Level fromJson(Map<String, dynamic> json) {
    return Level(
      levelName: json['level_name'],
      steps: List<String>.from(json['steps']),
    );
  }
}
