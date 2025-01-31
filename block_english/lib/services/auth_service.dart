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

  Future<Either<FailureModel, RegResponseModel>> postAuthRegister(
    String name,
    String username,
    String password,
    String role,
    int questiontype,
    String question,
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
          'questionType': questiontype,
          'question': question,
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

      _ref.watch(statusProvider).setUsername(username);

      if (response.data['role'] == 'student') {
        for (Map<String, dynamic> info in response.data['released']) {
          _ref.watch(statusProvider).setStudentStatus(
                intToSeason(info['season']),
                ReleaseStatus(info['level'], info['step']),
              );
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
      } else {
        _ref.watch(statusProvider).setRole(response.data['role']);
      }

      return Right(LoginResponseModel.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 200) {
        String errorcode = '';
        if (e.response?.data['username_correct'] == true) {
          errorcode = 'password';
        } else {
          errorcode = 'username';
        }

        return Left(
          FailureModel(
            statusCode: 200,
            detail: errorcode,
          ),
        );
      }
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

      _ref.watch(statusProvider).setName(
            response.data['name'],
          );

      _ref.watch(statusProvider).setUsername(
            response.data['username'],
          );

      if (response.data['role'] == 'student') {
        for (Map<String, dynamic> info in response.data['released']) {
          _ref.watch(statusProvider).setStudentStatus(
                intToSeason(info['season']),
                ReleaseStatus(info['level'], info['step']),
              );
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
      } else {
        _ref.watch(statusProvider).setRole(response.data['role']);
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
