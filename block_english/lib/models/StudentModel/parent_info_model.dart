class ParentInfoModel {
  String name;

  ParentInfoModel.fromJson(Map<String, dynamic> json) : name = json['name'];
}
