import 'dart:async';
import 'dart:typed_data';

import 'package:block_english/models/GameModel/game_group_model.dart';
import 'package:block_english/models/GameModel/game_room_model.dart';
import 'package:block_english/models/GameModel/game_student_solve_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/dio.dart';
import 'package:block_english/utils/status.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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
  final String _hostID = 'host_id';
  final String _join = 'join_room';
  final String _roomID = 'room_id';
  final String _participantID = 'participant_id';
  final String _participantName = 'participant_name';
  final String _solve = 'student_solve';
  final String _pnum = 'pnum';
  final String _file = 'file';

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
          _hostID: _ref.watch(statusProvider).username,
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

  Future<Either<FailureModel, Response>> postGameJoin(String pincode) async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.post(
        '/$_game/$_join',
        data: {
          _roomID: pincode,
          _participantID: _ref.watch(statusProvider).username,
          _participantName: _ref.watch(statusProvider).name,
        },
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }

  Future<Either<FailureModel, GameStudentSolveModel>> postGameSolve(
      String pincode, String participantId, int pnum, Uint8List png) async {
    final dio = _ref.watch(dioProvider);

    try {
      final response = await dio.post(
        '/$_game/$_solve',
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'accept': 'application/json',
          },
        ),
        data: FormData.fromMap({
          _file: MultipartFile.fromBytes(
            png,
            filename: 'ocr.png',
            contentType: MediaType('image', 'png'),
          ),
          _roomID: pincode,
          _participantID: participantId,
          _pnum: pnum,
        }),
      );
      return Right(GameStudentSolveModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(FailureModel(
        statusCode: e.response?.statusCode ?? 0,
        detail: e.response?.data['detail'] ?? "",
      ));
    }
  }
}
