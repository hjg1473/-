class StudentInfoModel {
  final String name;
  final int? teamId;

  StudentInfoModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        teamId = json['team_id'];
}
