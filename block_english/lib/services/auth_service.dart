import 'package:block_english/models/access_response_model.dart';
import 'package:block_english/models/login_response_model.dart';
import 'package:block_english/models/reg_response_model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:block_english/utils/storage.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

class AuthService {
  static const String _auth = "auth";
  static const String _register = "register";
  static const String _token = "token";
  static const String _access = "access";
  static const String _logout = "logout";

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

  Future<Response> postAuthLogout(String refreshToken) async {
    final dio = _ref.watch(dioProvider);
    final response = await dio.post(
      '/$_auth/$_logout',
      options: Options(
        headers: {
          'accept': 'application/json',
          'refresh-token': _ref.watch(secureStorageProvider).readRefreshToken(),
        },
      ),
    );
    return response;
  }
}

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  return AuthService(ref);
}
