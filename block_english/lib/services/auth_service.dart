import 'dart:convert';
import 'dart:io';

import 'package:block_english/models/access_response_model.dart';
import 'package:block_english/models/login_response_model.dart';
import 'package:block_english/models/refresh_response_model.dart';
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
  final String _refresh = "refresh";
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
      options: Options(contentType: Headers.jsonContentType),
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

  static Future<LoginResponseModel> postAuthToken(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$BASE_URL/$auth/$token");
    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName('utf-8'),
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw HttpException(detail);
    }
  }

  static Future<AccessReponseModel> postAuthAccess(String accessToken) async {
    final url = Uri.parse("$BASE_URL/$auth/$access");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "access-token": accessToken,
      },
    );
    if (response.statusCode == 200) {
      return AccessReponseModel.fromJson(jsonDecode(response.body));
    } else {
      final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw HttpException(detail);
    }
  }

  static Future<RefreshResponseModel> postAuthRefresh(
      String refreshToken) async {
    final url = Uri.parse("$BASE_URL/$auth/$refresh");
    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "refresh-token": refreshToken,
      },
    );
    if (response.statusCode == 200) {
      return RefreshResponseModel.fromJson(jsonDecode(response.body));
    } else {
      final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw HttpException(detail);
    }
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
