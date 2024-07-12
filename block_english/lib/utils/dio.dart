import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/storage.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio.g.dart';

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 5),
      baseUrl: BASEURL,
      validateStatus: (status) => (status == 200 || status == 201),
    ),
  );

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.clear();

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final accessToken = await storage.readAccessToken();
      if (options.headers[TOKENVALIDATE] == 'true') {
        options.headers.remove(TOKENVALIDATE);
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        var authDio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 5),
            baseUrl: BASEURL,
          ),
        );

        authDio.interceptors.clear();

        authDio.interceptors.add(InterceptorsWrapper(
          onError: (error, handler) async {
            if (error.response?.statusCode == 401) {
              await storage.removeTokens();
            }

            handler.next(error);
          },
        ));

        // add retries count

        final refreshToken = await storage.readRefreshToken();

        authDio.options.headers['accept'] = 'application/json';
        authDio.options.headers['refresh-token'] = '$refreshToken';

        try {
          final refreshTokenResponse = await authDio.post('/auth/refresh');

          final newAccessToken = refreshTokenResponse.data['access-token'];
          final newRefreshToken = refreshTokenResponse.data['refresh-token'];

          await storage.saveAccessToken(newAccessToken);
          await storage.saveRefreshToken(newRefreshToken);
        } on DioException catch (e) {
          return handler.next(DioException(requestOptions: e.requestOptions));
        }

        final response = await dio.request(
          error.requestOptions.path,
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters,
          cancelToken: error.requestOptions.cancelToken,
          options: Options(
            extra: error.requestOptions.extra,
            method: error.requestOptions.method,
          ),
        );
        return handler.resolve(response);
      }
    },
  ));

  return dio;
}
