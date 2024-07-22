class GroupInfoModel {
  final int id;
  final String name;
  final int count;

  GroupInfoModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        count = json['count'];
}
