import 'package:block_english/models/access_response_model.dart';
import 'package:block_english/models/login_response_model.dart';
import 'package:block_english/models/reg_response_model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'auth_service.g.dart';

class AuthService {
  final String _auth = "auth";
  final String _register = "register";
  final String _token = "token";
  final String _access = "access";
  final String _logout = "logout";

  static const String auth = "auth";
  static const String register = "register";
  static const String token = "token";
  static const String access = "access";
  static const String refresh = "refresh";
  static const String logout = "logout";

  late final AuthServiceRef _ref;

  AuthService(AuthServiceRef ref) {
    _ref = ref;
  }

  Future<RegResponseModel> postAuthRegister(
    String name,
    String username,
    String password,
    int age,
    String role,
  ) async {
    final dio = _ref.watch(dioProvider);
    final response = await dio.post(
      '/$_auth/$_register',
      options: Options(
        contentType: Headers.jsonContentType,
      ),
      data: {
        'name': name,
        'username': username,
        'password': password,
        'age': age,
        'role': role,
      },
    );
    return RegResponseModel.fromJson(response.data);
  }

  Future<LoginResponseModel> postAuthToken(
    String username,
    String password,
  ) async {
    final dio = _ref.watch(dioProvider);
    final response = await dio.post(
      '/$_auth/$_token',
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'accept': 'application/json'},
      ),
      data: {
        'username': username,
        'password': password,
      },
    );
    return LoginResponseModel.fromJson(response.data);
  }

  Future<AccessReponseModel> postAuthAccess() async {
    final dio = _ref.watch(dioProvider);
    final response = await dio.post('/$_auth/$_access',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {TOKEN_VALIDATE: 'true'},
        ));
    return AccessReponseModel.fromJson(response.data);
  }

  static Future<int> postAuthLogout(String refreshToken) async {
    final url = Uri.parse("$BASE_URL/$auth/$logout");
    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "refresh-token": refreshToken,
      },
    );
    return response.statusCode;
  }
}

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  return AuthService(ref);
}
