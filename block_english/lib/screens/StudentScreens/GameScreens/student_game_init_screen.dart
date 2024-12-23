import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentGameInitScreen extends ConsumerStatefulWidget {
  const StudentGameInitScreen({super.key});

  @override
  ConsumerState<StudentGameInitScreen> createState() =>
      _StudentGameInitScreenState();
}

class _StudentGameInitScreenState extends ConsumerState<StudentGameInitScreen> {
  int instructionIndex = 0;

  List<String> instructionTitle = [
    '1. 아래에 보여지는 한글 문장을 확인해 주세요',
    '2. 정답 블록을 조합해 촬영해요',
    '3. 게임이 끝나면 점수를 확인해요',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6FEFF),
      body: SizedBox(
        height: 1.sh,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 64,
                right: 64,
                top: 32,
              ).r,
              height: 307.r,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: SvgPicture.asset(
                          'assets/buttons/round_back_button.svg',
                          width: 48.r,
                          height: 48.r,
                        ),
                      ),
                      Text(
                        '게임 설명',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        width: 48.r,
                        height: 48.r,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 590.r,
                    height: 185.r,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 42.r,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (instructionIndex > 0) {
                              instructionIndex--;
                              setState(() {});
                            }
                          },
                          icon: SvgPicture.asset(
                            'assets/buttons/game_instruction_left_button.svg',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 28).r,
                          width: 470.r,
                          height: 185.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6699),
                            borderRadius: BorderRadius.circular(8.0).r,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                instructionTitle[instructionIndex],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/images/game_instruction_$instructionIndex.svg',
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          iconSize: 42.r,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (instructionIndex < 2) {
                              instructionIndex++;
                              setState(() {});
                            }
                          },
                          icon: SvgPicture.asset(
                            'assets/buttons/game_instruction_right_button.svg',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox()
                ],
              ),
            ),
            SquareButton(
              text: '게임 입장 핀 번호 입력하기',
              onPressed: () =>
                  Navigator.of(context).pushNamed('/stud_game_enter_screen'),
            ),
          ],
        ),
      ),
    );
  }
}
