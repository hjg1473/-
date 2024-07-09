import 'dart:convert';
import 'dart:io';
import 'package:block_english/models/super_info_response_model.dart';
import 'package:block_english/utils/dio.dart';
import 'package:dio/dio.dart';

class SuperService {
  static String baseUrl = "http://35.208.231.160";
  static const String _super = "super";
  static const String group = "group";
  static const String info = "info";

  static Future<SuperInfoResponseModel> getInfo(String accesstoken) async {
    // final url = Uri.parse("$baseUrl/$_super/$info");
    // final response = await http.get(url, headers: {
    //   "accept": "application/json",
    //   "Authorization": "Bearer $accesstoken",
    // });

    // if (response.statusCode == 200) {
    //   return SuperInfoResponseModel.fromJson(jsonDecode(response.body));
    // } else {
    //   final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
    //   throw HttpException(detail);
    // }
    final dio = ref.watch(dioProvider);
  }
}
