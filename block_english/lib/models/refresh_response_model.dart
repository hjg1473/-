class RefreshResponseModel {
  final String accessToken;
  final String tokenType;
  final String role;
  final String refreshToken;

  RefreshResponseModel.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'],
        tokenType = json['token_type'],
        role = json['role'],
        refreshToken = json['refresh_token'];
}
