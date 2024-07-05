class SuperInfoResponseModel {
  final String name;

  SuperInfoResponseModel.fromJson(Map<String, dynamic> json)
      : name = json['name'];
}
