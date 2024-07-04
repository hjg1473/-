import 'dart:convert';
import 'dart:io';

import 'package:block_english/models/access_reponse_model.dart';
import 'package:block_english/models/login_response_model.dart';
import 'package:block_english/models/refresh_response_model.dart';
import 'package:block_english/models/reg_response_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String baseUrl = "http://35.208.231.160";
  static const String auth = "auth";
  static const String register = "register";
  static const String token = "token";
  static const String access = "access";
  static const String refresh = "refresh";

  static Future<RegResponseModel> postAuthRegister(
    String name,
    String username,
    String password,
    int age,
    String role,
  ) async {
    final url = Uri.parse("$baseUrl/$auth/$register");
    var data = {
      'name': name,
      'username': username,
      'password': password,
      'age': "$age",
      'role': role,
    };
    var body = jsonEncode(data);

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return RegResponseModel.fromJson(jsonDecode(response.body));
    } else {
      final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw HttpException(detail);
    }
  }

  static Future<LoginResponseModel> postAuthToken(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/$auth/$token");
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
    final url = Uri.parse("$baseUrl/$auth/$access");
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
    final url = Uri.parse("$baseUrl/$auth/$refresh");
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
}
