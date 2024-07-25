import 'package:block_english/models/AuthModel/access_response_model.dart';
import 'package:block_english/models/AuthModel/exist_check_model.dart';
import 'package:block_english/models/AuthModel/login_response_model.dart';
import 'package:block_english/models/AuthModel/reg_response_model.dart';
import 'package:block_english/models/FailureModel/failure_model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
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
  static const String _username_phone = "username_phone";
  static const String _verify = "verify";
  static const String _register = "register";
  static const String _token = "token";
  static const String _access = "access";
  static const String _logout = "logout";

  late final AuthServiceRef _ref;

  AuthService(AuthServiceRef ref) {
    _ref = ref;
  }

  Future<Either<FailureModel, ExistCheckModel>> postAuthExistVerify(
      String username, String phonenumber) async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.post(
        '/$_auth/$_username_phone/$_verify',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'accept': 'application/json'},
        ),
        data: {
          'username': username,
          'phone_number': phonenumber,
        },
      );

      return Right(ExistCheckModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, RegResponseModel>> postAuthRegister(
    String name,
    String username,
    String password,
    int age,
    String role,
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
          'age': age,
          'role': role,
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
      final response = await dio.post('/$_auth/$_access',
          options: Options(
            contentType: Headers.jsonContentType,
            headers: {TOKENVALIDATE: 'true'},
          ));
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
