import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:block_english/utils/status.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_service.g.dart';

@Riverpod(keepAlive: true)
StudentService studentService(StudentServiceRef ref) {
  return StudentService(ref);
}

class StudentService {
  static const String _student = 'student';
  static const String _parent = 'parent';
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

  Future<Either<FailureModel, PinEnterResponse>> postPinEnter(
    int pinNumber,
  ) async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.post(
        '/$_student/pin/enter',
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

      if (response.data['detail'] == '유효하지 않은 핀코드입니다.') {
        return Left(FailureModel(
          statusCode: 0,
          detail: response.data['detail'],
        ));
      }
      if (response.data['team_id'] != null) {
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
      } else if (response.data['name'] != null) {
        debugPrint('parent_name: ${response.data['name']}');
        _ref.watch(statusProvider).setParent(response.data['name']);
      }

      return Right(PinEnterResponse.fromJson(response.data));
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

  Future<Either<FailureModel, List<StudyInfoModel>>> getMonitoringCorrectRate(
    int season,
  ) async {
    try {
      final dio = _ref.watch(dioProvider);
      final response = await dio.get(
        '/$_student/monitoring_correct_rate',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
            'Content-Type': 'application/json',
          },
        ),
        queryParameters: {
          'season': season,
        },
      );
      debugPrint(response.data.toString());
      return Right((response.data['seasons'] as List).map((e) {
        return StudyInfoModel.fromJson(e);
      }).toList());
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'],
      ));
    }
  }

  Future<Either<FailureModel, IncorrectModel>> getMonitoringIncorrect(
    int season,
  ) async {
    try {
      final dio = _ref.watch(dioProvider);
      final response = await dio.get(
        '/$_student/monitoring_incorrect',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
            'Content-Type': 'application/json',
          },
        ),
        queryParameters: {
          'season': season,
        },
      );

      return Right(IncorrectModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'],
      ));
    }
  }

  Future<Either<FailureModel, StudyTimeModel>> getMonitoringEtc() async {
    try {
      final dio = _ref.watch(dioProvider);
      final response = await dio.get(
        '/$_student/monitoring_etc',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
            'Content-Type': 'application/json',
          },
        ),
      );

      return Right(StudyTimeModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'],
      ));
    }
  }
}
