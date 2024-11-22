import 'package:block_english/screens/SuperScreens/GameScreens/super_game_end_screen.dart';
import 'package:block_english/utils/game.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SuperGameMainScreen extends ConsumerStatefulWidget {
  const SuperGameMainScreen({
    super.key,
  });

  @override
  ConsumerState<SuperGameMainScreen> createState() =>
      _SuperGameMainScreenState();
}

class _SuperGameMainScreenState extends ConsumerState<SuperGameMainScreen> {
  int index = 0;
  int done = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(gameNotifierProvider).remainingTime == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SuperGameEndScreen(),
        ));
      });
    }
    final players = ref.watch(gameNotifierProvider).players;

    return Scaffold(
      backgroundColor: const Color(0xFFE7FFD1),
      body: SizedBox(
        height: 1.sh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 32,
                left: 44,
                right: 44,
                bottom: 24,
              ).r,
              child: SizedBox(
                width: 724.r,
                height: 251.r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 350.r,
                      height: 251.r,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: 60.r,
                                height: 48.r,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8.0).r,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24.sp,
                                  ),
                                ),
                              ),
                              IntrinsicWidth(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 48.r,
                                  padding: const EdgeInsets.all(8.0).r,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0).r,
                                  ),
                                  child: Text(
                                    '${ref.watch(gameNotifierProvider).remainingTime ~/ 60}:${(ref.watch(gameNotifierProvider).remainingTime % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: 350.r,
                            height: 90.r,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0).r,
                            ),
                            child: Text(
                              ref
                                  .watch(gameNotifierProvider)
                                  .problems[index]
                                  .value,
                              style: TextStyle(
                                color: const Color(0xFF7C7C7C),
                                fontWeight: FontWeight.w800,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 133.r,
                              height: 48.r,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (index != 0) {
                                        setState(() {
                                          index--;
                                        });
                                      }
                                    },
                                    icon: SvgPicture.asset(
                                      'assets/buttons/super_game_left_button.svg',
                                      width: 48.r,
                                      height: 48.r,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (index <
                                          ref
                                                  .watch(gameNotifierProvider)
                                                  .problems
                                                  .length -
                                              1) {
                                        setState(() {
                                          index++;
                                        });
                                      }
                                    },
                                    icon: SvgPicture.asset(
                                      'assets/buttons/super_game_right_button.svg',
                                      width: 48.r,
                                      height: 48.r,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      width: 352.r,
                      height: 251.r,
                      padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 24)
                          .r,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 320.r,
                            height: 20.r,
                            child: Row(
                              children: [
                                Text(
                                  '게임 진행 현황',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18.sp,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                SizedBox(
                                  width: 16.r,
                                ),
                                Text(
                                  '${players.length}명 중 $done명 완료',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.sp,
                                    color: const Color(0xFFAAAAAA),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 320.r,
                            height: 166.r,
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 306.r,
                                  height: 50.r,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ).r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA9EA70),
                                    borderRadius: BorderRadius.circular(8.0).r,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        players.values.elementAt(index),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Color(
                                            0xFF3B5C1E,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        '대기중',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(
                                            0xFF3B5C1E,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Container(
                                  height: 8.r,
                                );
                              },
                              itemCount: players.length,
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
              text: '종료하기',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
