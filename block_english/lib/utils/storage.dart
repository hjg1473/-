import 'package:block_english/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage storage(StorageRef ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
SecureStorage secureStorage(SecureStorageRef ref) {
  final FlutterSecureStorage storage = ref.read(storageProvider);
  return SecureStorage(storage: storage);
}

class SecureStorage {
  final FlutterSecureStorage storage;
  SecureStorage({
    required this.storage,
  });

  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await storage.write(key: REFRESHTOKEN, value: refreshToken);
      debugPrint('[SECURE_STORAGE] saveRefreshToken: $refreshToken');
    } catch (e) {
      debugPrint("[ERR] RefreshToken 저장 실패: $e");
    }
  }

  Future<String?> readRefreshToken() async {
    try {
      final refreshToken = await storage.read(key: REFRESHTOKEN);
      debugPrint('[SECURE_STORAGE] readRefreshToken: $refreshToken');
      return refreshToken;
    } catch (e) {
      debugPrint("[ERR] RefreshToken 불러오기 실패: $e");
      return null;
    }
  }

  Future<void> saveAccessToken(String accessToken) async {
    try {
      await storage.write(key: ACCESSTOKEN, value: accessToken);
      debugPrint('[SECURE_STORAGE] saveAccessToken: $accessToken');
    } catch (e) {
      debugPrint("[ERR] AccessToken 저장 실패: $e");
    }
  }

  Future<String?> readAccessToken() async {
    try {
      final accessToken = await storage.read(key: ACCESSTOKEN);
      debugPrint('[SECURE_STORAGE] readAccessToken: $accessToken');
      return accessToken;
    } catch (e) {
      debugPrint("[ERR] AccessToken 불러오기 실패: $e");
      return null;
    }
  }

  removeTokens() async {
    await storage.delete(key: ACCESSTOKEN);
    debugPrint('[SECURE_STORAGE] removeTokens: removed access token');
    await storage.delete(key: REFRESHTOKEN);
    debugPrint('[SECURE_STORAGE] removeTokens: removed refresh token');
  }
}
