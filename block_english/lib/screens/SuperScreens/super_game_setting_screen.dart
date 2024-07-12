import 'package:block_english/utils/colors.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/round_corner_route_button.dart';
import 'package:flutter/material.dart';

class SuperGameSettingScreen extends StatefulWidget {
  const SuperGameSettingScreen({super.key});

  @override
  State<SuperGameSettingScreen> createState() => _SuperGameSettingScreenState();
}

class _SuperGameSettingScreenState extends State<SuperGameSettingScreen> {
  late double playerSliderValue;
  late int playerSliderCurrent;
  late double timeSliderValue;
  late int timeSliderCurrent;
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
    playerSliderValue = 0.0;
    playerSliderCurrent = 0;
    timeSliderValue = 0.0;
    timeSliderCurrent = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Block English',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "게임 설정",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  const Text(
                    "게임에 참여할 학생 수",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: lightPrimary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        '$playerSliderCurrent',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    "명",
                    style: TextStyle(
                      color: lightPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: playerSliderValue,
              max: 30,
              divisions: 6,
              label: '${playerSliderValue.round()}',
              onChanged: (value) {
                setState(
                  () {
                    playerSliderValue = value;
                    playerSliderCurrent = value.toInt();
                  },
                );
              },
            ),
            const Divider(
              thickness: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  const Text(
                    "문제 별 제한 시간",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: lightPrimary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        '$timeSliderCurrent',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    "초",
                    style: TextStyle(
                      color: lightPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: timeSliderValue,
              max: 60,
              divisions: 6,
              label: '${timeSliderValue.round()}',
              onChanged: (value) {
                setState(
                  () {
                    timeSliderValue = value;
                    timeSliderCurrent = value.toInt();
                  },
                );
              },
            ),
            const Divider(
              thickness: 1,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Text(
                "문제 세트 선택",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomDropdown<String>(
                hintText: '문제 세트를 선택하세요',
                items: problemSetList,
                onChanged: (value) {},
                decoration: const CustomDropdownDecoration(
                  hintStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  closedFillColor: lightSurface,
                  expandedFillColor: lightSurface,
                  closedShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 40.0),
              child: RoundCornerRouteButton(
                text: "게임 방 개설",
                routeName: '/super_game_screen',
                width: 330,
                height: 55,
                type: ButtonType.outlined,
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
