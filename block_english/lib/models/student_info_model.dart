class StudentInfoModel {
  final String name;
  final String age;
  final String? teamId;

  StudentInfoModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'].toString(),
        teamId = json['team_id'];
}
