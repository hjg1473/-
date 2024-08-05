class UsernameDuplicationResponseModel {
  final int available;

  UsernameDuplicationResponseModel.fromJson(Map<String, dynamic> json)
      : available = json['detail'];
}
