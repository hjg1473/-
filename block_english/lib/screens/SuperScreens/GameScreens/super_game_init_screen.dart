import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:block_english/models/GameModel/game_group_model.dart';
import 'package:block_english/services/game_service.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperGameInitScreen extends ConsumerStatefulWidget {
  const SuperGameInitScreen({super.key});

  @override
  ConsumerState<SuperGameInitScreen> createState() =>
      _SuperGameInitScreenState();
}

class _SuperGameInitScreenState extends ConsumerState<SuperGameInitScreen> {
  List<GameGroupModel> groupList = [];
  List<String> nameList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getGroupModel();
    });
  }

  getGroupModel() async {
    final result = await ref.watch(gameServiceProvider).getGameGroup();

    result.fold(
      (failure) {
        //TODO: error handling
      },
      (gameGroupModels) {
        setState(() {
          groupList = gameGroupModels;
          nameList = gameGroupModels.map((group) => group.name).toList();
        });
      },
    );
  }

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
                      Column(
                        children: [
                          Text(
                            '게임 진행',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '게임 시작 전 우리반 진도를 확인해보세요',
                            style: TextStyle(
                              fontSize: 14.r,
                              fontWeight: FontWeight.w700,
                              color: const Color(0x88000000),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        //TODO: 게임설명 추가
                        icon: SvgPicture.asset(
                          'assets/buttons/round_question_button.svg',
                          width: 48.r,
                          height: 48.r,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 200.r,
                        height: 60.r,
                        child: CustomDropdown(
                          items: nameList,
                          onChanged: (val) {},
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0).r,
                          color: Colors.white,
                        ),
                        width: 400.r,
                        height: 60.r,
                      ),
                    ],
                  ),
                  const SizedBox()
                ],
              ),
            ),
            SquareButton(
              text: '게임 방 생성하기',
              onPressed: () =>
                  Navigator.of(context).pushNamed('/super_game_setting_screen'),
            ),
          ],
        ),
      ),
    );
  }
}
