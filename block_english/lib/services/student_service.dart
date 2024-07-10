import 'dart:convert';
import 'dart:io';

import 'package:block_english/models/student_info_model.dart';
import 'package:block_english/utils/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_service.g.dart';

@Riverpod(keepAlive: true)
StudentService studentService(StudentServiceRef ref) {
  return StudentService(ref);
}

class StudentService {
  static const String _student = 'student';
  static const String _info = 'info';
  static late final StudentServiceRef _ref;

  StudentService(StudentServiceRef ref) {
    _ref = ref;
  }

  static Future<StudentInfoModel> getStudentInfo() async {
    // final url = Uri.parse('$baseUrl/$student/$info');
    // final response = await http.get(
    //   url,
    //   headers: {
    //     "accept": "application/json",
    //     "Authorization": "Bearer $accessToken",
    //   },
    // );
    // if (response.statusCode == 200) {
    //   return StudentInfoModel.fromJson(jsonDecode(response.body));
    // } else {
    //   final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
    //   throw HttpException(detail);
    // }
    final dio = _ref.watch(dioProvider);
    final response = await dio.get('/$_student/$_info');
    return StudentInfoModel.fromJson(response.data);
  }
}
