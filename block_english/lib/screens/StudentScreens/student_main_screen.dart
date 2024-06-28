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
            onPressed: () {},
          ),
          centerTitle: true,
          title: const Text("Block English"),
          bottom: const TabBar(tabs: <Widget>[
            Tab(
              text: "문제 풀기",
            ),
            Tab(
              text: "실전 문제 풀기",
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
              child: Text('실전 문제 풀기'),
            ),
            const Center(
              child: Text('게임하기'),
            ),
            const Center(
              child: Text('프로필'),
            ),
          ],
        ),
      ),
    );
  }
}
