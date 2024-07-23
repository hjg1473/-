import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GroupSettingScreen extends StatefulWidget {
  const GroupSettingScreen({super.key});

  @override
  State<GroupSettingScreen> createState() => _GroupSettingScreenState();
}

class _GroupSettingScreenState extends State<GroupSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('그룹 설정'),
          backgroundColor: Colors.white,
        ),
        body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(' 그룹명 변경'),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '그룹명을 입력해 주세요',
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('그룹 입장 핀코드 생성'),
                SizedBox(
                  height: 10,
                ),
                FilledButton(onPressed: null, child: Text('PIN 코드 생성하기')),
              ],
            )));
  }
}
