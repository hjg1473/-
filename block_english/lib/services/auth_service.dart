import 'dart:convert';

import 'package:block_english/models/login_response_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String baseUrl = "http://35.208.231.160";
  static const String auth = "auth";
  static const String register = "register";
  static const String token = "token";

  static Future<int> postAuthRegister(
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
    return response.statusCode;
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
      var detail = jsonDecode(response.body)['detail'];
      throw Exception(detail);
    }
  }
}
