import 'package:block_english/models/MonitoringModel/study_info_model.dart';

class GroupMonitoringModel {
  List<StudyInfoModel> studyInfo = [];
  String weakest = '';
  String created = '';
  int peoples;

  GroupMonitoringModel.fromJson(Map<String, dynamic> json)
      : studyInfo = (json['detail'] as List)
            .map((e) => StudyInfoModel.fromJson(e))
            .toList(),
        weakest = json['weakest'],
        created = json['created'],
        peoples = json['peoples'];
}
