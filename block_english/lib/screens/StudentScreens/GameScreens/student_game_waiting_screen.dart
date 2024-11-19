import 'dart:async';
import 'dart:convert';

import 'package:block_english/screens/StudentScreens/GameScreens/student_game_camera_screen.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/game.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StudentGameWaitingScreen extends ConsumerStatefulWidget {
  const StudentGameWaitingScreen({super.key, required this.pinCode});
  final String pinCode;

  @override
  ConsumerState<StudentGameWaitingScreen> createState() =>
      _StudentGameWaitingScreenState();
}

class _StudentGameWaitingScreenState
    extends ConsumerState<StudentGameWaitingScreen> {
  int _countdown = 0;
  Timer? _countdownTimer;
  double _waitingTextTopPosition = 0.3.sh;
  double _countdownTopPosition = -0.2.sh;
  double _opacity = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(gameProvider).initStudentSocket(
          widget.pinCode, ref.watch(statusProvider).username);
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _channel = WebSocketChannel.connect(
    //     Uri.parse(
    //         '$BASEWSURL/${widget.pinCode}/${ref.watch(statusProvider).username}'),
    //   );
    //   _channel.stream.listen((message) {
    //     final decodedMessage = jsonDecode(message) as Map<String, dynamic>;

    //     for (final val in decodedMessage.entries) {
    //       debugPrint('key: ${val.key}, value: ${val.value}');
    //     }
    //     if (decodedMessage.containsKey('message')) {
    //       if (decodedMessage['message'] == 'startCountDown') {
    //         debugPrint('startCountDown');
    //         setState(() {
    //           _gameStarted = true;
    //           _startCountdown();
    //         });
    //       } else if (decodedMessage['message'] == 'GameStart') {
    //         setState(() {
    //           duration = decodedMessage['duration'];
    //         });
    //       }
    //     }
    //     if (decodedMessage.containsKey('problems')) {
    //       for (final problem in decodedMessage['problems']) {
    //         ref.watch(gameProvider).problems[problem['problem_id']] =
    //             problem['koreaProblem'];
    //       }

    //       final jsonString = jsonEncode({
    //         "message": "Ack",
    //       });
    //       debugPrint(jsonString);
    //       _channel.sink.add(jsonString);
    //     }
    //   }, onError: (error) {
    //     debugPrint('[WS:ERROR] $error');
    //   }, onDone: () {
    //     debugPrint('[WS:DISCONNECT]');
    //   });
    //   setState(() {
    //     _channelInitialized = true;
    //   });
    // });
  }

  void _startCountdown() {
    setState(() {
      _waitingTextTopPosition = 0.5.sh; // Move waiting text down
      _opacity = 0.0; // Fade out waiting text
      _countdown = 3;
      _countdownTopPosition = 0.3.sh; // Position countdown from above
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        _countdownTimer?.cancel();
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const StudentGameCameraScreen(
          problemIndex: 0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(gameProvider).gameStarted) _startCountdown();

    return Scaffold(
      backgroundColor: const Color(0xFFFFE0EB),
      body: SizedBox(
        height: 1.sh,
        child: Stack(
          children: [
            // Waiting text with slide-down animation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: _waitingTextTopPosition,
              left: 0.2.sw,
              right: 0.2.sw,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _opacity,
                child: Text(
                  ref.watch(gameProvider).channelInitialized
                      ? '모두가 들어올 때까지 기다려주세요!'
                      : '접속중입니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFFF43B4),
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // Countdown text with falling effect
            if (ref.watch(gameProvider).gameStarted)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                top: _countdownTopPosition,
                left: 0.2.sw,
                right: 0.2.sw,
                child: Text(
                  '$_countdown',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFFF43B4),
                    fontSize: 80.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            //TODO: add motion_13
          ],
        ),
      ),
    );
  }
}
