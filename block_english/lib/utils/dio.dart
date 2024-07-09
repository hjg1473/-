import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio.g.dart';

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 5),
      baseUrl: BASE_URL,
      validateStatus: (status) => (status == 200 || status == 201),
    ),
  );

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.clear();

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final accessToken = await storage.readAccessToken();
      options.headers['Authorization'] = 'Bearer $accessToken';
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        var authDio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 5),
            baseUrl: BASE_URL,
          ),
        );

        authDio.interceptors.clear();

        authDio.interceptors.add(InterceptorsWrapper(
          onError: (error, handler) async {
            if (error.response?.statusCode == 401) {
              await storage.removeTokens();
            }

            //TODO: 로그인 만료 표시 후 처음 화면으로 돌아가기
            handler.reject(error);
          },
        ));

        final refreshToken = await storage.readRefreshToken();

        authDio.options.headers['accept'] = 'application/json';
        authDio.options.headers['refresh-token'] = '$refreshToken';

        final refreshTokenResponse = await authDio.get('/auth/refresh');

        final newAccessToken = refreshTokenResponse.data['access-token'];
        final newRefreshToken = refreshTokenResponse.data['refresh-token'];

        await storage.saveAccessToken(newAccessToken);
        await storage.saveRefreshToken(newRefreshToken);

        //TODO: retry failed request again.
      }
    },
  ));

  return dio;
}
