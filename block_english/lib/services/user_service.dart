import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_service.g.dart';

@Riverpod(keepAlive: true)
UserService userService(UserServiceRef ref) {
  return UserService(ref);
}

class UserService {
  static const String _user = 'users';

  static late final UserServiceRef _ref;
  UserService(UserServiceRef ref) {
    _ref = ref;
  }

  Future<Either<FailureModel, SuccessModel>> putUsersPassword(
    String password,
    String newPassword,
  ) async {
    final dio = _ref.watch(dioProvider);

    try {
      var response = await dio.put(
        '/$_user/password',
        options: Options(
          headers: {
            'accept': 'application/json',
            'content-type': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
        data: {
          'password': password,
          'new_password': newPassword,
        },
      );
      return Right(
        SuccessModel(
          statusCode: response.statusCode ?? 0,
          detail: response.data['detail'] ?? "",
        ),
      );
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
