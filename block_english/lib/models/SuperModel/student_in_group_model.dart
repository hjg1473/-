class StudentInGroupModel {
  final int id;
  final String name;

  StudentInGroupModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
