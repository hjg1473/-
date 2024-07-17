class SuperGroupModel {
  final int id;
  final String name;

  SuperGroupModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
