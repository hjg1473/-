import 'dart:ui';
import 'package:block_english/models/SuperModel/super_group_model.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/image_card_button.dart';
import 'package:block_english/widgets/no_image_card_button.dart';
import 'package:block_english/widgets/profile_card_widget.dart';
import 'package:block_english/widgets/round_corner_route_button.dart';
import 'package:block_english/widgets/profile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuperMainScreen extends StatelessWidget {
  const SuperMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Block English',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/setting_screen');
            },
          ),
          bottom: const TabBar(tabs: [
            Tab(
              text: '대시보드',
            ),
            Tab(
              text: '게임',
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "프로필",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return FutureBuilder(
                        future: ref.watch(superServiceProvider).getSuperInfo(),
                        builder: (context, snapshot) {
                          String text = '';
                          if (!snapshot.hasData) {
                            return const Text('Loading...');
                          }
                          snapshot.data!.fold(
                            (failure) {
                              text = failure.detail;
                            },
                            (superinfo) {
                              text = superinfo.name;
                            },
                          );
                          return ProfileCard(name: text);
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.black54,
                            size: 15,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '학생들에게 표시되는 이름이에요',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "그룹 관리",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return Expanded(
                        child: FutureBuilder(
                          future:
                              ref.watch(superServiceProvider).getGroupList(),
                          builder: (context, snapshot) {
                            List<SuperGroupModel> groups = [];
                            String error = '';
                            if (!snapshot.hasData) {
                              return const Text('Loading...');
                            }
                            snapshot.data!.fold(
                              (failure) {
                                error = failure.detail;
                              },
                              (groupList) {
                                groups = groupList;
                              },
                            );

                            return error.isEmpty
                                ? ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    itemCount: groups.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var group = groups[index];
                                      return ProfileButton(
                                        name: group.name,
                                        groupId: group.id,
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 20),
                                  )
                                : // TODO: handle error
                                ProfileButton(name: error);
                          },
                        ),
                      );
                    },
                  ),
                  const Center(
                    child: RoundCornerRouteButton(
                      text: "그룹 추가",
                      routeName: '/super_add_group_screen',
                      width: 320,
                      height: 50,
                      type: ButtonType.filled,
                      bold: true,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "게임 방 만들기",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RoundCornerRouteButton(
                    text: "게임 생성",
                    routeName: '/super_game_setting_screen',
                    width: 330,
                    height: 50,
                    type: ButtonType.filled,
                    radius: 10,
                    bold: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "문제 세트 관리",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          ImageCard(name: "3반 문제 세트"),
                          SizedBox(
                            height: 15,
                          ),
                          NoImageCard(name: "1반 문제 세트"),
                          SizedBox(
                            height: 15,
                          ),
                          NoImageCard(name: "2반 문제 세트"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RoundCornerRouteButton(
                    text: "문제 세트 추가",
                    routeName: '/super_game_screen',
                    width: 330,
                    height: 50,
                    type: ButtonType.outlined,
                    radius: 10,
                    bold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
