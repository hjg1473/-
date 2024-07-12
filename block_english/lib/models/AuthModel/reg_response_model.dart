class RegResponseModel {
  final String detail;

  RegResponseModel.fromJson(Map<String, dynamic> json)
      : detail = json['detail'];
}
