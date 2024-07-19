class SuperGroupModel {
  final int id;
  final String name;
  final int count;

  SuperGroupModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        count = json['count'];
}
