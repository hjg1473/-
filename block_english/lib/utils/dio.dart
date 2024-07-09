import 'package:block_english/utils/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 5),
      baseUrl: "http://35.208.231.160",
      validateStatus: (status) => (status == 200 || status == 201),
    ),
  );

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(TokenInterceptor(storage.storage));

  return dio;
});

class TokenInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage storage;

  TokenInterceptor(this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: implement onError
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
    super.onResponse(response, handler);
  }
}
