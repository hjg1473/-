class UserMonitoringIncorrectModel {
  List<dynamic> weakParts = [];
  String weakest = '';
  String? recentProblem;
  String? recentAnswer;
  String recentDetail;

  UserMonitoringIncorrectModel.fromJson(Map<String, dynamic> json)
      : weakParts = json['weak_parts'],
        weakest = json['weakest'],
        recentProblem = json['recent_problem'],
        recentAnswer = json['recent_answer'],
        recentDetail = json['recent_detail'];
}
