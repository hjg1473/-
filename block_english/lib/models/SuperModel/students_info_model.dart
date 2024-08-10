class StudentsInfoModel {
  final int id;
  final String name;

  StudentsInfoModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
