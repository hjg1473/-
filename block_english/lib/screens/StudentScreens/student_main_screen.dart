import 'package:block_english/screens/StudentScreens/student_game_screen.dart';
import 'package:flutter/material.dart';

class StudentMainScreen extends StatelessWidget {
  const StudentMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 3,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/setting_screen');
            },
          ),
          centerTitle: true,
          title: const Text("Block English"),
          bottom: const TabBar(tabs: <Widget>[
            Tab(
              text: "문제 풀기",
            ),
            Tab(
              text: "실전 문제",
            ),
            Tab(
              text: "게임하기",
            ),
            Tab(
              text: "프로필",
            ),
          ]),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Column(
                    children: [Text("chapter1")],
                  ),
                ),
              ],
            ),
            const Center(
              child: Text('실전 문제'),
            ),
            const StudentGameScreen(),
            const Center(
              child: Text('프로필'),
            ),
          ],
        ),
      ),
    );
  }
}
