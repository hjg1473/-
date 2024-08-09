class StudyInfoModel {
  int? season;
  List<double>? incorrectRateNormal;
  List<double>? incorrectRateAI;
  int? releasedLevel;
  int? releasedStep;

  StudyInfoModel.fromJson(Map<String, dynamic> json)
      : season = json['season'],
        incorrectRateNormal = json['incorrect_rate_normal'],
        incorrectRateAI = json['incorrect_rate_ai'],
        releasedLevel = json['released_level'],
        releasedStep = json['released_step'];
}
