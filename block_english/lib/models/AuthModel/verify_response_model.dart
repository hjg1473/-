class VerifyResponseModel {
  final String detail;

  VerifyResponseModel.fromJson(Map<String, dynamic> json)
      : detail = json['detail'];
}
