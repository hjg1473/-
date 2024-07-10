import 'package:block_english/models/Super/super_group_model.dart';
import 'package:block_english/models/Super/super_info_response_model.dart';
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

  // static Future<List<SuperGroupModel>> getGroupList(String accesstoken) async {
  //   List<SuperGroupModel> groupList = [];
  //   final url = Uri.parse("$baseUrl/$_super/$_group");
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       "accept": "application/json",
  //       "Authorization": "Bearer $accesstoken",
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final List<dynamic> groups =
  //         jsonDecode(utf8.decode(response.bodyBytes))['groups'];
  //     for (var group in groups) {
  //       groupList.add(SuperGroupModel.fromJson(group));
  //     }
  //     return groupList;
  //   } else {
  //     final detail = jsonDecode(utf8.decode(response.bodyBytes))['detail'];
  //     throw HttpException(detail);
  //   }
  // }
}

@Riverpod(keepAlive: true)
SuperService superService(SuperServiceRef ref) {
  return SuperService(ref);
}
