import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'super_service.g.dart';

class SuperService {
  final String _super = "super";
  final String _group = "group";
  final String _info = "info";
  late final SuperServiceRef _ref;

  SuperService(SuperServiceRef ref) {
    _ref = ref;
  }

  Future<Either<FailureModel, SuperInfoModel>> getSuperInfo() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/$_super/$_info',
        options: Options(
          headers: {TOKENVALIDATE: 'true'},
        ),
      );
      return Right(SuperInfoModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, List<GroupInfoModel>>> getGroupList() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/$_super/$_group',
        options: Options(
          headers: {TOKENVALIDATE: 'true'},
        ),
      );
      return Right((response.data['groups'] as List)
          .map((e) => GroupInfoModel.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, CreateGroupResponseModel>> postCreateGroup(
      String name) async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.post(
        '/super/create/group',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
        data: {
          'name': name,
          'grade': 4,
        },
      );
      return Right(CreateGroupResponseModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, List<StudentInGroupModel>>> getStudentInGroup(
      int groupId) async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/super/student_in_group/$groupId',
        options: Options(
          headers: {'accept': 'application/json', TOKENVALIDATE: 'true'},
        ),
      );
      return Right((response.data['groups'] as List)
          .map((e) => StudentInGroupModel.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }
}

@Riverpod(keepAlive: true)
SuperService superService(SuperServiceRef ref) {
  return SuperService(ref);
}
