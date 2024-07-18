import 'package:block_english/screens/StudentScreens/student_game_screen.dart';
import 'package:block_english/screens/StudentScreens/student_profile_screen.dart';
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
        ),
        bottomNavigationBar: const TabBar(tabs: <Widget>[
          Tab(
            icon: Icon(Icons.menu_book_rounded),
            text: "문제 풀기",
          ),
          Tab(
            icon: Icon(Icons.looks_two_outlined),
            text: "실전 문제",
          ),
          Tab(
            icon: Icon(Icons.games_outlined),
            text: "게임하기",
          ),
          Tab(
            icon: Icon(Icons.person_outline_rounded),
            text: "프로필",
          ),
        ]),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Placeholder(),
            Center(
              child: Text('실전 문제'),
            ),
            StudentGameScreen(),
            StudentProfileScreen(),
          ],
        ),
      ),
    );
  }
}
