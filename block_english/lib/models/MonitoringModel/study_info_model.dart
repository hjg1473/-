class StudyInfoModel {
  int? season;
  List<double>? correctRateNormal;
  List<double>? correctRateAI;
  int? releasedLevel;
  int? releasedStep;

  StudyInfoModel.fromJson(Map<String, dynamic> json)
      : season = json['season'],
        correctRateNormal = (json['correct_rate_normal'] as List)
            .map((e) => e.toDouble() as double)
            .toList(),
        correctRateAI = (json['correct_rate_ai'] as List)
            .map((e) => e.toDouble() as double)
            .toList(),
        releasedLevel = json['released_level'],
        releasedStep = json['released_step'];
}
