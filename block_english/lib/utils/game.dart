import 'dart:convert';

import 'package:block_english/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'game.g.dart';

class Game {
  Map<int, String> problems = {};
  WebSocketChannel? _channel;
  bool gameStarted = false;
  bool channelInitialized = false;
  int duration = 0;

  initStudentSocket(
    String pinCode,
    String username,
  ) {
    _channel = WebSocketChannel.connect(
      Uri.parse('$BASEWSURL/$pinCode/$username'),
    );

    _channel!.stream.listen((message) {
      final decodedMessage = jsonDecode(message) as Map<String, dynamic>;

      for (final val in decodedMessage.entries) {
        debugPrint('key: ${val.key}, value: ${val.value}');
      }
      if (decodedMessage.containsKey('message')) {
        if (decodedMessage['message'] == 'startCountDown') {
          debugPrint('startCountDown');
          gameStarted = true;
        } else if (decodedMessage['message'] == 'GameStart') {
          duration = decodedMessage['duration'];
        }
      }
      if (decodedMessage.containsKey('problems')) {
        for (final problem in decodedMessage['problems']) {
          problems[problem['problem_id']] = problem['koreaProblem'];
        }

        final jsonString = jsonEncode({
          "message": "Ack",
        });
        debugPrint(jsonString);
        _channel!.sink.add(jsonString);
      }
    }, onError: (error) {
      debugPrint('[WS:ERROR] $error');
    }, onDone: () {
      debugPrint('[WS:DISCONNECT]');
    });
    channelInitialized = true;
    debugPrint(
        '[initStudentSocket] channelInitialized set to $channelInitialized');
  }

  closeSocket() {}
}

@Riverpod(keepAlive: true)
Game game(GameRef ref) {
  return Game();
}
