import 'package:block_english/models/AuthModel/username_dupcheck_response_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:block_english/utils/status.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  return AuthService(ref);
}

class AuthService {
  static const String _auth = "auth";
  static const String _register = "register";
  static const String _token = "token";
  static const String _access = "access";
  static const String _logout = "logout";

  late final AuthServiceRef _ref;

  AuthService(AuthServiceRef ref) {
    _ref = ref;
  }

  Future<Either<FailureModel, UsernameDupCheckResponseModel>>
      postAuthUsernameDuplication(String username) async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.post(
        '/$_auth/username_duplication',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'accept': 'application/json'},
        ),
        data: {
          'username': username,
        },
      );

      return Right(UsernameDupCheckResponseModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  // TODO: Update Reg Request
  Future<Either<FailureModel, RegResponseModel>> postAuthRegister(
    String name,
    String username,
    String password,
    String role,
    int questiontype,
    String question,
    List<int> seasons,
  ) async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.post(
        '/$_auth/$_register',
        options: Options(
          contentType: Headers.jsonContentType,
        ),
        data: {
          'name': name,
          'username': username,
          'password': password,
          'role': role,
          'questiontype': questiontype,
          'question': question,
          'seasons': seasons,
        },
      );
      return Right(RegResponseModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, LoginResponseModel>> postAuthToken(
    String username,
    String password,
  ) async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.post(
        '/$_auth/$_token',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'accept': 'application/json'},
        ),
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.data['username_correct'] == false ||
          response.data['password_correct'] == false) {
        throw DioException(
            requestOptions: response.requestOptions, response: response);
      }

      _ref.watch(statusProvider).setName(response.data['name']);

      if (response.data['role'] == 'student') {
        _ref.watch(statusProvider).setStudentStatus(
              response.data['released'],
              response.data['team_id'],
            );
      }

      return Right(LoginResponseModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? '',
      ));
    }
  }

  Future<Either<FailureModel, AccessReponseModel>> postAuthAccess() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.post(
        '/$_auth/$_access',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {TOKENVALIDATE: 'true'},
        ),
      );

      _ref.watch(statusProvider).setName(response.data['name']);

      if (response.data['role'] == 'student') {
        _ref.watch(statusProvider).setStudentStatus(
              response.data['released'],
              response.data['team_id'],
            );
      }

      return Right(AccessReponseModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? '',
      ));
    }
  }

  Future<Either<FailureModel, Response>> postAuthLogout(
      String refreshToken) async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.post(
        '/$_auth/$_logout',
        options: Options(
          headers: {
            'accept': 'application/json',
            'refresh-token': refreshToken,
          },
        ),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? '',
      ));
    }
  }
}
