import 'package:block_english/models/MonitoringModel/weak_part_model.dart';

class IncorrectModel {
  WeakPartModel weakParts;
  String weakest = '';
  String recentDetail;

  IncorrectModel.fromJson(Map<String, dynamic> json)
      : weakParts = WeakPartModel.fromJson(json['weak_parts']),
        weakest = json['weakest'],
        recentDetail = json['recent_detail'];
}
