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
  bool _countdownStarted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameNotifierProvider.notifier).initStudentSocket(
          widget.pinCode, ref.watch(statusProvider).username);
    });
  }

  void _startCountdown() {
    _countdownStarted = true;
    debugPrint('[_startCoundDown] called');
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

        ref.read(gameNotifierProvider.notifier).startCountdown();
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
    final gameState = ref.watch(gameNotifierProvider);

    if (gameState.gameStarted && !_countdownStarted) _startCountdown();

    return Scaffold(
      backgroundColor: const Color(0xFFFFE0EB),
      body: SizedBox(
        height: 1.sh,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: _waitingTextTopPosition,
              left: 0.2.sw,
              right: 0.2.sw,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _opacity,
                child: Text(
                  gameState.channelInitialized
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
            if (gameState.gameStarted)
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
          ],
        ),
      ),
    );
  }
}
