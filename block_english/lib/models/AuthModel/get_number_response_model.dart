class GetNumberResponseModel {
  final String detail;

  GetNumberResponseModel.fromJson(Map<String, dynamic> json)
      : detail = json['detail'];
}
