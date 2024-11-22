import 'package:block_english/services/game_service.dart';
import 'package:block_english/utils/game.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class SuperGameEndScreen extends ConsumerStatefulWidget {
  const SuperGameEndScreen({
    super.key,
  });

  @override
  ConsumerState<SuperGameEndScreen> createState() => _SuperGameEndScreenState();
}

class _SuperGameEndScreenState extends ConsumerState<SuperGameEndScreen> {
  List<Pair<String, int>> rankList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRank();
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE7FFD1),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 33.0).r,
              child: SizedBox(
                  width: 724.r,
                  height: 252.r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 410.r,
                        height: 252.r,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 410.r,
                              height: 46.r,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF93E54C),
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
                              width: 410.r,
                              height: 206.r,
                              padding:
                                  const EdgeInsets.fromLTRB(36, 20, 46, 30).r,
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
                                                    fontWeight: FontWeight.w800,
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
                                                    fontWeight: FontWeight.w800,
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
                                                    fontWeight: FontWeight.w800,
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
                      Container(
                        width: 298.r,
                        height: 252.r,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8.0).r,
                        ),
                      ),
                    ],
                  )),
            ),
            Row(
              children: [
                Expanded(
                  child: SquareButton(
                    text: '종료하기',
                    backgroundColor: const Color(0xFF505050),
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: SquareButton(
                    text: '계속하기',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
