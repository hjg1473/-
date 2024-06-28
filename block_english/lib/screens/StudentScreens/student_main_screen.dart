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
          actions: const [],
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
        body: const TabBarView(
          children: <Widget>[
            Center(
              child: Text('문제 풀기'),
            ),
            Center(
              child: Text('실전 문제 풀기'),
            ),
            Center(
              child: Text('게임하기'),
            ),
            Center(
              child: Text('프로필'),
            ),
          ],
        ),
      ),
    );
  }
}
