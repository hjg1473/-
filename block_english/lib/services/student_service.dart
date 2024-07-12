import 'package:block_english/models/StudentModel/student_info_model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:dio/dio.dart';
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

  Future<StudentInfoModel> getStudentInfo() async {
    final dio = _ref.watch(dioProvider);
    final response = await dio.get(
      '/$_student/$_info',
      options: Options(
        headers: {TOKENVALIDATE: 'true'},
      ),
    );
    return StudentInfoModel.fromJson(response.data);
  }
}
