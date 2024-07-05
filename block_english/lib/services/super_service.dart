import 'dart:convert';
import 'dart:io';
import 'package:block_english/models/Super/super_group_model.dart';
import 'package:block_english/models/Super/super_info_response_model.dart';
import 'package:http/http.dart' as http;

class SuperService {
  static String baseUrl = "http://35.208.231.160";
  static const String _super = "super";
  static const String group = "group";
  static const String info = "info";

  static Future<SuperInfoResponseModel> getInfo(String accesstoken) async {
    final url = Uri.parse("$baseUrl/$_super/$info");
    final response = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer $accesstoken",
      },
    );

    if (response.statusCode == 200) {
      return SuperInfoResponseModel.fromJson(jsonDecode(response.body));
    } else {
      final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw HttpException(detail);
    }
  }

  static Future<List<SuperGroupModel>> getGroupList(String accesstoken) async {
    List<SuperGroupModel> groupList = [];
    final url = Uri.parse("$baseUrl/$_super/$group");
    final response = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer $accesstoken",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> groups =
          jsonDecode(utf8.decode(response.bodyBytes))['groups'];
      for (var group in groups) {
        groupList.add(SuperGroupModel.fromJson(group));
      }
      return groupList;
    } else {
      final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw HttpException(detail);
    }
  }
}
