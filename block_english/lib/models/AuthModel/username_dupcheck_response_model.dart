class UsernameDupCheckResponseModel {
  final int available;

  UsernameDupCheckResponseModel.fromJson(Map<String, dynamic> json)
      : available = json['detail'];
}
