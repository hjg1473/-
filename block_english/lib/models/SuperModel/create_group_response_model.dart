class CreateGroupResponseModel {
  final String detail;

  CreateGroupResponseModel.fromJson(Map<String, dynamic> json)
      : detail = json['detail'];
}
