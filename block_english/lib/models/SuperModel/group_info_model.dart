class GroupInfoModel {
  final int id;
  final String name;
  final int count;
  final String detail;

  GroupInfoModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        count = json['count'],
        detail = json['detail'];
}
