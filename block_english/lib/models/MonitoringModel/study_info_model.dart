class StudyInfoModel {
  int? season;
  List<double>? incorrectRateNormal;
  List<double>? incorrectRateAI;
  int? releasedLevel;
  int? releasedStep;

  StudyInfoModel.fromJson(Map<String, dynamic> json)
      : season = json['season'],
        incorrectRateNormal = (json['incorrect_rate_normal'] as List)
            .map((e) => e.toDouble() as double)
            .toList(),
        incorrectRateAI = (json['incorrect_rate_ai'] as List)
            .map((e) => e.toDouble() as double)
            .toList(),
        releasedLevel = json['released_level'],
        releasedStep = json['released_step'];
}
