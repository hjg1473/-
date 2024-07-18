import 'dart:ui';

import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/round_corner_route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SuperGameSettingScreen extends StatefulWidget {
  const SuperGameSettingScreen({super.key});

  @override
  State<SuperGameSettingScreen> createState() => _SuperGameSettingScreenState();
}

class _SuperGameSettingScreenState extends State<SuperGameSettingScreen> {
  late int problemNumber;
  late int timeMinutes;
  final List<String> problemSetList = [
    '3반 문제 세트',
    '1반 시험 문제',
    '3반 의문문 수업',
    '3반 명령문 수업',
  ];
  String? selectedProblemSet;

  @override
  void initState() {
    super.initState();
    problemNumber = 14;
    timeMinutes = 7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '게임',
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "문장 퀴즈",
              style: TextStyle(
                color: Color(0xFF313131),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              '블록을 이용해 시간 안에 영어 문장 맞추기',
              style: TextStyle(
                color: Color(0xFF313131),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBDBDB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    const Text(
                      '문제 수',
                      style: TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                problemNumber--;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            icon: const Icon(Icons.remove),
                          ),
                          SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                '$problemNumber',
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                problemNumber++;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '게임 시간 (분)',
                      style: TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                timeMinutes--;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            icon: const Icon(Icons.remove),
                          ),
                          SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                '$timeMinutes',
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                timeMinutes++;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
              child: RoundCornerRouteButton(
                text: "방 생성하기",
                routeName: '/super_game_code_screen',
                width: 330,
                height: 60,
                type: ButtonType.filled,
                radius: 10,
                bold: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
