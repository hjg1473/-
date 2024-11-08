import 'package:block_english/models/model.dart';

class UserSummaryModel {
  WeakPartModel weakParts;
  StudyInfoModel rates;
  int totalStudyTime;
  int streamStudyDay;

  UserSummaryModel.fromJson(Map<String, dynamic> json)
      : weakParts = WeakPartModel.fromJson(json['weak_parts']),
        rates = StudyInfoModel.fromJson(json['rates'][0]),
        totalStudyTime = json['totalStudyTime'] ?? 0,
        streamStudyDay = json['streamStudyDay'] ?? 0;
}
