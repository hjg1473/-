class AccessReponseModel {
  final String detail;
  final String role;

  AccessReponseModel.fromJson(Map<String, dynamic> json)
      : detail = json['detail'],
        role = json['role'];
}
