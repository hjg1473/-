import 'dart:io';
import 'dart:typed_data';

import 'package:block_english/models/ProblemModel/problem_ocr_model.dart';
import 'package:block_english/models/ProblemModel/problems_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:block_english/utils/status.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'problem_service.g.dart';

@Riverpod(keepAlive: true)
ProblemService problemService(ProblemServiceRef ref) {
  return ProblemService(ref);
}

class ProblemService {
  static const String _problem = 'problem';
  static const String _practice = 'practice';
  static const String _info = 'info';
  static const String _set = 'set';
  static const String _ocr = 'solve_OCR';

  static late final ProblemServiceRef _ref;

  ProblemService(ProblemServiceRef ref) {
    _ref = ref;
  }

  Future<Either<FailureModel, Response>> postProblemEnd() async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.post(
        '/$_problem/study_end',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
        queryParameters: {
          'mode_str': modeToString(_ref.watch(statusProvider).studentMode),
        },
      );
      for (Map<String, dynamic> info in response.data['released']) {
        _ref.watch(statusProvider).setStudentStatus(
              intToSeason(info['season']),
              ReleaseStatus(info['level'], info['step']),
            );
      }

      return Right(response);
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, ProblemPracticeInfoModel>> getProblemPracticeInfo(
      int season) async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.get(
        '/$_problem/$_practice/$_info',
        queryParameters: {'season': season},
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
      );
      return Right(ProblemPracticeInfoModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(
        FailureModel(
          statusCode: e.response?.statusCode ?? 0,
          detail: e.response?.data['detail'] ?? "",
        ),
      );
    }
  }

  Future<Either<FailureModel, ProblemsModel>> getProblemPracticeSet(
      int season, int level, int step) async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.get(
        '/$_problem/$_practice/$_set',
        queryParameters: {'season': season, 'level': level, 'step': step},
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
      );

      return Right(ProblemsModel.fromJson(response.data, StudyMode.practice));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, ProblemOcrModel>> postProblemOCR(
    Uint8List png,
    int problemId,
  ) async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.post(
        '/$_problem/$_ocr',
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(
            png,
            filename: 'ocr.png',
            contentType: MediaType('image', 'png'),
          ),
          'problem_id': problemId,
        }),
      );

      return Right(ProblemOcrModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }
}
