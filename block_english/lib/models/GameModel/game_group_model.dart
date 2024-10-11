class GameGroupModel {
  final int id;
  final String name;

  GameGroupModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
