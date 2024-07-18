import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'problem_service.g.dart';

@Riverpod(keepAlive: true)
ProblemService problemService(ProblemServiceRef ref) {
  return ProblemService(ref);
}

class ProblemService {
  static const String _problem = 'problem';
  static const String _info = 'info';

  static late final ProblemServiceRef _ref;

  ProblemService(ProblemServiceRef ref) {
    _ref = ref;
  }

  Future<Either<FailureModel, ProblemInfoModel>> getProblemInfo() async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.get(
        '/$_problem/$_info',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
      );

      return Right(ProblemInfoModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(
        FailureModel(
          statusCode: e.response?.statusCode ?? 0,
          detail: e.response?.data['detail'] ?? "",
        ),
      );
    }
  }
}
