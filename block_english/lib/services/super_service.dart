import 'dart:convert';
import 'dart:io';
import 'package:block_english/models/super_info_response_model.dart';
import 'package:block_english/utils/dio.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'super_service.g.dart';

class SuperService {
  static const String _super = "super";
  static const String _group = "group";
  static const String _info = "info";
  static late final SuperServiceRef _ref;

  SuperService(SuperServiceRef ref) {
    _ref = ref;
  }

  static Future<SuperInfoResponseModel> getInfo() async {
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
    final dio = _ref.watch(dioProvider);
    final response = await dio.get('/$_super/$_info');
    return SuperInfoResponseModel.fromJson(response.data);
  }
}

@Riverpod(keepAlive: true)
SuperService superService(SuperServiceRef ref) {
  return SuperService(ref);
}
