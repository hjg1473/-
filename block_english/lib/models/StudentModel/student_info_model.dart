import 'package:block_english/utils/constants.dart';

class StudentInfoModel {
  final String name;
  final String age;
  final int? teamId;

  StudentInfoModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = gradelist[json['age']],
        teamId = json['team_id'];
}
