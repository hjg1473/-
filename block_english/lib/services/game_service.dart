import 'package:block_english/models/GameModel/game_group_model.dart';
import 'package:block_english/models/GameModel/game_room_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:block_english/utils/status.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_service.g.dart';

@Riverpod(keepAlive: true)
GameService gameService(GameServiceRef ref) {
  return GameService(ref);
}

class GameService {
  final String _game = 'game';
  final String _group = 'group';
  final String _create = 'create_room';

  late final GameServiceRef _ref;

  GameService(GameServiceRef ref) {
    _ref = ref;
  }

  Future<Either<FailureModel, List<GameGroupModel>>> getGameGroup() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/$_game/$_group',
        options: Options(
          headers: {
            'accept': 'application/json',
            TOKENVALIDATE: 'true',
          },
        ),
      );

      List<GameGroupModel> gameGroupModels = [];

      for (Map<String, dynamic> groupData in response.data['groups']) {
        gameGroupModels.add(GameGroupModel.fromJson(groupData));
      }

      return Right(gameGroupModels);
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, GameRoomModel>> postGameCreate() async {
    final dio = _ref.watch(dioProvider);
    try {
      final response = await dio.post(
        '/$_game/$_create',
        data: {
          'host_id': _ref.watch(statusProvider).username,
        },
      );

      return Right(GameRoomModel.fromjson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }
}
