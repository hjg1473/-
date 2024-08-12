import 'package:block_english/models/StudentModel/released_info_model.dart';

class EnterGroupResponse {
  int? teamId;
  String? groupName;
  String? groupDetail;
  List<ReleasedInfoModel>? releasedGroup;

  EnterGroupResponse.fromJson(Map<String, dynamic> json)
      : teamId = json['team_id'],
        groupName = json['group_name'],
        groupDetail = json['group_detail'],
        releasedGroup = json['released_group'] == null
            ? null
            : (json['released_group'] as List)
                .map((e) => ReleasedInfoModel.fromJson(e))
                .toList();
}
