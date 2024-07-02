class LoginResponseModel {
  final String accessToken;
  final String tokenType;
  final String role;

  LoginResponseModel.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'],
        tokenType = json['token_type'],
        role = json['role'];
}
