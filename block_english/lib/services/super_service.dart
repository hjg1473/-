import 'package:block_english/models/SuperModel/pin_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'super_service.g.dart';

class SuperService {
  static const String _super = "super";
  static const String _parent = "parent";
  static const String _group = "group";
  static const String _info = "info";
  static const String _getpin = "get_pin";
  static const String _remove = "remove";
  static const String _groupId = "group_id";
  static const String _groupName = 'group_name';
  static const String _groupDetail = 'group_detail';
  static const String _groupUpdate = 'group_update';
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

  Future<Either<FailureModel, List<StudentsInfoModel>>> getChildList() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/$_super/$_parent/get_child',
        options: Options(
          headers: {TOKENVALIDATE: 'true'},
        ),
      );
      return Right((response.data['children'] as List)
          .map((e) => StudentsInfoModel.fromJson(e))
          .toList());
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
      String name, String detailText) async {
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
          'detail': detailText,
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

  Future<Either<FailureModel, List<StudentsInfoModel>>> getStudentInGroup(
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
          .map((e) => StudentsInfoModel.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, PinModel>> getParentPinNumber() async {
    try {
      final dio = _ref.watch(dioProvider);
      final response = await dio.get(
        '/$_super/$_parent/$_getpin',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
      );

      return Right(PinModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'],
      ));
    }
  }

  Future<Either<FailureModel, PinModel>> postPinNumber(int groupId) async {
    try {
      final dio = _ref.watch(dioProvider);
      final response = await dio.post(
        '/$_super/$_getpin',
        options: Options(
          headers: {'accept': 'application/json', TOKENVALIDATE: 'true'},
        ),
        data: {
          _groupId: groupId.toString(),
        },
      );

      return Right(PinModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'],
      ));
    }
  }

  Future<Either<FailureModel, Response>> putGroupUpdate(
      int groupId, String groupName, String detail) async {
    try {
      final dio = _ref.watch(dioProvider);
      final response = await dio.put('/$_super/$_groupUpdate',
          options: Options(
            contentType: Headers.jsonContentType,
            headers: {TOKENVALIDATE: 'true'},
          ),
          data: {
            _groupId: groupId,
            _groupName: groupName,
            _groupDetail: detail,
          });

      return Right(response);
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'],
      ));
    }
  }

  // Future<Either<FailureModel, Response>> putRemoveStudentInGroup(
  //     int studentId) async {
  //   final dio = _ref.watch(dioProvider);

  //   final response = await dio.get(
  //     '/$_super/$_group/$_remove/${studentId.toString()}',

  //   );
  // }
}

@Riverpod(keepAlive: true)
SuperService superService(SuperServiceRef ref) {
  return SuperService(ref);
}
