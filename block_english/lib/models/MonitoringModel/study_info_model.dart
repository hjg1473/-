class StudyInfoModel {
  int? season;
  List<double>? correctRateNormal;
  List<double>? correctRateAI;
  int? releasedLevel;
  int? releasedStep;
  List<List<String>>? stepList;

  StudyInfoModel.fromJson(Map<String, dynamic> json)
      : season = json['season'],
        correctRateNormal = (json['correct_rate_normal'] as List)
            .map((e) => e.toDouble() as double)
            .toList(),
        correctRateAI = (json['correct_rate_ai'] as List)
            .map((e) => e.toDouble() as double)
            .toList(),
        releasedLevel = json['released_level'],
        releasedStep = json['released_step'],
        stepList = (json['levels'] != null && json['levels'] is List)
            ? (json['levels'] as List).map((level) {
                List<String> steps = (level['steps'] as List)
                    .map((step) => 'Step ${step + 1}')
                    .toList();
                return steps;
              }).toList()
            : [];
}
