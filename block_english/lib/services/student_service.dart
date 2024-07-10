import 'dart:convert';
import 'dart:io';

import 'package:block_english/models/student_info_model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:http/http.dart' as http;

class StudentService {
  static String student = 'student';
  static String info = 'info';

  static Future<StudentInfoModel> getStudentInfo(String accessToken) async {
    final url = Uri.parse('$BASE_URL/$student/$info');
    final response = await http.get(
      url,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200) {
      return StudentInfoModel.fromJson(jsonDecode(response.body));
    } else {
      final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
      throw HttpException(detail);
    }
  }
}
