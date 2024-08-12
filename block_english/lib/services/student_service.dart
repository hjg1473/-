import 'package:block_english/models/StudentModel/parent_info_model.dart';
import 'package:block_english/models/StudentModel/enter_group_response_model.dart';
import 'package:block_english/models/SuccessModel/success_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:block_english/utils/status.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_service.g.dart';

@Riverpod(keepAlive: true)
StudentService studentService(StudentServiceRef ref) {
  return StudentService(ref);
}

class StudentService {
  static const String _student = 'student';
  static const String _parent = 'parent';
  static const String _group = 'group';
  static const String _info = 'info';
  static late final StudentServiceRef _ref;

  StudentService(StudentServiceRef ref) {
    _ref = ref;
  }

  Future<Either<FailureModel, List<int>>> getSeasonInfo() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/$_student/season_info',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
      );

      List<int> seasonList = (response.data['seasons'] as List)
          .map((item) => int.parse(item.toString()))
          .toList();
      _ref.watch(statusProvider).setAvailableSeason(seasonList);

      return Right(seasonList);
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? '',
      ));
    }
  }

  Future<Either<FailureModel, SuccessModel>> putUpdateSeason(
      List<int> seasons) async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.put(
        '/$_student/update_season',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
        data: {
          'season': seasons,
        },
      );

      return Right(
        SuccessModel(
          statusCode: response.statusCode ?? 0,
          detail: response.data['detail'],
        ),
      );
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? '',
      ));
    }
  }

  Future<Either<FailureModel, EnterGroupResponse>> postGroupEnter(
    int pinNumber,
  ) async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.post(
        '/$_student/$_group/enter',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
        data: {
          'pin_number': pinNumber,
        },
      );

      if (response.data['detail'] != null) {
        return Left(FailureModel(
          statusCode: 0,
          detail: response.data['detail'],
        ));
      }

      _ref.watch(statusProvider).setGroup(
            response.data['team_id'],
            response.data['group_name'],
          );
      if (response.data['released_group'] != null) {
        for (Map<String, dynamic> info in response.data['released_group']) {
          _ref.watch(statusProvider).setGroupStatus(
                intToSeason(info['season']),
                ReleaseStatus(info['level'], info['step']),
              );
        }
      }

      return Right(EnterGroupResponse.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? '',
      ));
    }
  }

  Future<Either<FailureModel, StudentInfoModel>> getStudentInfo() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/$_student/$_info',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
      );

      return Right(StudentInfoModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? '',
      ));
    }
  }

  Future<Either<FailureModel, ParentInfoModel>> getParentInfo() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/$_student/$_parent/$_info',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
      );
      return Right(ParentInfoModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? '',
      ));
    }
  }
}
