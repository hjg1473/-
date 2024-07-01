import 'dart:convert';

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
}
