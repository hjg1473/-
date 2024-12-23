import 'dart:async';
import 'dart:convert';
import 'package:block_english/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'game.g.dart';

class Pair<K, V> {
  final K key;
  final V value;

  Pair(this.key, this.value);
}

class GameState {
  final List<Pair<int, String>> problems;
  final bool gameStarted;
  final bool channelInitialized;
  final int duration;
  final int remainingTime;
  final String pinCode;
  final Map<String, String> players;
  final bool noMoreProblem;

  GameState({
    this.problems = const [],
    this.gameStarted = false,
    this.channelInitialized = false,
    this.duration = 0,
    this.remainingTime = 0,
    this.pinCode = "",
    this.players = const {},
    this.noMoreProblem = false,
  });

  GameState copyWith({
    List<Pair<int, String>>? problems,
    bool? gameStarted,
    bool? channelInitialized,
    int? duration,
    int? remainingTime,
    String? pinCode,
    Map<String, String>? players,
    bool? noMoreProblem,
  }) {
    return GameState(
      problems: problems ?? this.problems,
      gameStarted: gameStarted ?? this.gameStarted,
      channelInitialized: channelInitialized ?? this.channelInitialized,
      duration: duration ?? this.duration,
      remainingTime: remainingTime ?? this.remainingTime,
      pinCode: pinCode ?? this.pinCode,
      players: players ?? this.players,
      noMoreProblem: noMoreProblem ?? this.noMoreProblem,
    );
  }
}

@Riverpod(keepAlive: true)
class GameNotifier extends _$GameNotifier {
  WebSocketChannel? _channel;
  Timer? _timer;

  void startCountdown() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime > 0) {
        state = state.copyWith(remainingTime: state.remainingTime - 1);
      } else {
        timer.cancel();
      }
    });
  }

  void stopCountdown() {
    _timer?.cancel();
    state = state.copyWith(remainingTime: 0);
  }

  void sendGameStartMessage(
      int level, int season, int difficulty, int duration) {
    if (!state.channelInitialized) return;
    final jsonString = jsonEncode({
      "message": "GameStart",
      "level": level,
      "season": season,
      "difficulty": difficulty,
      "duration": duration,
    });
    debugPrint(jsonString);
    _channel!.sink.add(jsonString);
  }

  void sendMoreProblemMeesage() {
    if (!state.channelInitialized) return;
    final jsonString = jsonEncode({
      "message": "MoreProblems",
      "problemNumber": state.problems.length,
    });
    debugPrint(jsonString);
    _channel!.sink.add(jsonString);
  }

  @override
  GameState build() {
    return GameState();
  }

  void initSuperSocket(String pinCode, String username) {
    _channel = WebSocketChannel.connect(
      Uri.parse('$BASEWSURL/$pinCode/$username'),
    );
    state = state.copyWith(pinCode: pinCode);

    _channel!.stream.listen((message) {
      final decodedMessage = jsonDecode(message) as Map<String, dynamic>;

      for (final val in decodedMessage.entries) {
        debugPrint('key: ${val.key}, value: ${val.value}');
      }

      if (decodedMessage.containsKey('message')) {
        if (decodedMessage['message'] == 'startCountDown') {
          state = state.copyWith(gameStarted: true);
        } else if (decodedMessage['message'] == 'GameStart') {
          state = state.copyWith(
            duration: decodedMessage['duration'],
            remainingTime: decodedMessage['duration'],
          );
          startCountdown();
        }
      }
      if (decodedMessage.containsKey('participant_name')) {
        final newPlayers = Map<String, String>.from(state.players);
        newPlayers[decodedMessage['participant_id']] =
            (decodedMessage['participant_name'] ?? 'UNKNOWN');

        state = state.copyWith(players: newPlayers);
      }
      if (decodedMessage.containsKey('problems')) {
        final List<Pair<int, String>> problems = [];
        for (final problem in decodedMessage['problems']) {
          problems.add(Pair(problem['problem_id'], problem['koreaProblem']));
        }
        state = state.copyWith(problems: problems, gameStarted: true);
      }
    }, onError: (error) {
      debugPrint('[WS:ERROR] $error');
    }, onDone: () {
      debugPrint('[WS:DISCONNECT]');
    });
    state = state.copyWith(channelInitialized: true);
  }

  void initStudentSocket(String pinCode, String username) {
    _channel = WebSocketChannel.connect(
      Uri.parse('$BASEWSURL/$pinCode/$username'),
    );

    state = state.copyWith(pinCode: pinCode);

    _channel!.stream.listen((message) {
      final decodedMessage = jsonDecode(message) as Map<String, dynamic>;

      if (decodedMessage.containsKey('message')) {
        if (decodedMessage['message'] == 'startCountDown') {
          state = state.copyWith(gameStarted: true);
        } else if (decodedMessage['message'] == 'GameStart') {
          state = state.copyWith(
            duration: decodedMessage['duration'],
            remainingTime: decodedMessage['duration'],
          );
        }
      }
      if (decodedMessage.containsKey('problems')) {
        final problems = List<Pair<int, String>>.from(state.problems);

        final receivedProblems = decodedMessage['problems'] as List;

        if (receivedProblems.isEmpty) {
          state = state.copyWith(noMoreProblem: true);
        }
        for (final problem in receivedProblems) {
          problems.add(Pair(problem['problem_id'], problem['koreaProblem']));
        }
        state = state.copyWith(problems: problems);
        _channel!.sink.add(jsonEncode({"message": "Ack"}));
      }
    }, onError: (error) {
      debugPrint('[WS:ERROR] $error');
    }, onDone: () {
      debugPrint('[WS:DISCONNECT]');
    });

    state = state.copyWith(channelInitialized: true);
  }

  void closeSocket() {
    state = state.copyWith(
      problems: const [],
      gameStarted: false,
      channelInitialized: false,
      duration: 0,
      remainingTime: 0,
      pinCode: "",
      players: const {},
      noMoreProblem: false,
    );
    stopCountdown();
    _channel?.sink.close();
    _channel = null;
  }
}
