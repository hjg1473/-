class StudentInfoModel {
  final String name;
  final int teamId;
  final String groupName;

  StudentInfoModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        teamId = json['team_id'],
        groupName = json['group_name'];
}
