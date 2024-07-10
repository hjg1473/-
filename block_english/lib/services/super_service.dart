import 'package:block_english/models/super_info_response_model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
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

  Future<SuperInfoResponseModel> getSuperInfo() async {
    final dio = _ref.watch(dioProvider);
    final response = await dio.get(
      '/$_super/$_info',
      options: Options(
        headers: {TOKEN_VALIDATE: 'true'},
      ),
    );
    return SuperInfoResponseModel.fromJson(response.data);
  }
}

@Riverpod(keepAlive: true)
SuperService superService(SuperServiceRef ref) {
  return SuperService(ref);
}
