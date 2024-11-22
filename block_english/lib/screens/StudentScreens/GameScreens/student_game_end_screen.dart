import 'package:block_english/screens/StudentScreens/GameScreens/student_game_init_screen.dart';
import 'package:block_english/services/game_service.dart';
import 'package:block_english/utils/game.dart';
import 'package:block_english/utils/status.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class StudentGameEndScreen extends ConsumerStatefulWidget {
  const StudentGameEndScreen({
    super.key,
  });

  @override
  ConsumerState<StudentGameEndScreen> createState() =>
      _StudentGameEndScreenState();
}

class _StudentGameEndScreenState extends ConsumerState<StudentGameEndScreen> {
  List<Pair<String, int>> rankList = [];

  void showGameResultDialog(BuildContext context) {
    String username = ref.watch(statusProvider).username;
    int index = rankList.indexWhere((pair) => pair.key == username);
    int score = rankList[index].value;

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 1.sw,
            height: 1.sh,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32,
                    left: 64,
                    right: 64,
                  ).r,
                  child: SizedBox(
                    width: 684.r,
                    height: 242.r,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 400.r,
                          height: 242.r,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 400.r,
                                height: 46.r,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0XFFFF6699),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ).r,
                                ),
                                child: Text(
                                  'Game Ranking',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                width: 400.r,
                                height: 196.r,
                                padding:
                                    const EdgeInsets.fromLTRB(36, 20, 36, 20).r,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                  ).r,
                                ),
                                child: SizedBox(
                                  width: 328.r,
                                  height: 156.r,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 80.r,
                                        height: 129.r,
                                        child: rankList.length >= 2
                                            ? Column(
                                                children: [
                                                  Text(
                                                    '2위',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  Lottie.asset(
                                                    'assets/lottie/motion_19.json',
                                                  ),
                                                  Text(rankList[1].key),
                                                ],
                                              )
                                            : null,
                                      ),
                                      SizedBox(
                                        width: 100.r,
                                        height: 156.r,
                                        child: rankList.isNotEmpty
                                            ? Column(
                                                children: [
                                                  Text(
                                                    '1위',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  Lottie.asset(
                                                    'assets/lottie/motion_20.json',
                                                  ),
                                                  Text(rankList[0].key),
                                                ],
                                              )
                                            : null,
                                      ),
                                      SizedBox(
                                        width: 80.r,
                                        height: 129.r,
                                        child: rankList.length >= 3
                                            ? Column(
                                                children: [
                                                  Text(
                                                    '3위',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  Lottie.asset(
                                                    'assets/lottie/motion_21.json',
                                                  ),
                                                  Text(rankList[2].key),
                                                ],
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 248.r,
                          height: 186.r,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: 248.r,
                                height: 46.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6699),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(8.0).r,
                                    topRight: const Radius.circular(8.0).r,
                                  ),
                                ),
                                child: Text(
                                  'My Score',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 248.r,
                                height: 140.r,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: const Radius.circular(8.0).r,
                                    bottomRight: const Radius.circular(8.0).r,
                                  ),
                                ),
                                child: SizedBox(
                                  width: 208.r,
                                  height: 102.r,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('점수'),
                                          Text('$score'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('풀이시간'),
                                          Text(
                                            ref
                                                .watch(gameNotifierProvider)
                                                .duration
                                                .toString(),
                                          )
                                        ],
                                      ),
                                      const Divider(
                                        thickness: 1,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('등수'),
                                          Text('${index + 1}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SquareButton(
                  text: '다음으로',
                  onPressed: () {
                    ref.watch(gameNotifierProvider.notifier).closeSocket();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                        return const StudentGameInitScreen();
                      }),
                      ModalRoute.withName('/stud_main_screen'),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _fetchRank() async {
    final response = await ref
        .watch(gameServiceProvider)
        .postGameSuperStudentScore(ref.watch(gameNotifierProvider).pinCode);

    response.fold((failure) {
      //TODO: error handling
    }, (gameSuperStudentScore) {
      rankList = gameSuperStudentScore.studentList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRank();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          debugPrint('showDialog called');
          showGameResultDialog(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEF4),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 44,
              right: 44,
              top: 24,
              bottom: 16,
            ).r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 220.r,
                    height: 24.r,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 220.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(45).r,
                          ),
                        ),
                        Container(
                          width: 220.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA3C2),
                            borderRadius: BorderRadius.circular(45).r,
                          ),
                        ),
                        Positioned(
                          left: 190.r,
                          child: SizedBox(
                            width: 61.r,
                            height: 32.r,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/progressbar/progress_block.svg',
                                ),
                                Text(
                                  'OVER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 41, left: 95).r,
                      child: Lottie.asset('assets/lottie/motion_14.json')),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
