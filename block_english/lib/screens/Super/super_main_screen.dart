import 'package:block_english/widgets/profile_button.dart';
import 'package:block_english/widgets/profile_card_widget.dart';
import 'package:flutter/material.dart';

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
          leading: const IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black87,
            ),
            onPressed: null,
          ),
          bottom: const TabBar(tabs: [
            Tab(
              text: '학생 관리',
            ),
            Tab(
              text: '게임 생성',
            ),
          ]),
        ),
        body: const TabBarView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  child: Text(
                    "프로필",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: ProfileCard(
                    name: "드림초 영어쌤",
                    id: "deurimET123",
                  ),
                ),
                Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 35.0, vertical: 5.0),
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
                SizedBox(
                  height: 5,
                ),
                Divider(
                  thickness: 1,
                  indent: 30,
                  endIndent: 30,
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                  child: Text(
                    "그룹 관리",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          child: ProfileButton(
                            name: "3학년 1반",
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          child: ProfileButton(
                            name: "2학년 1반",
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          child: ProfileButton(
                            name: "2학년 2반",
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          child: ProfileButton(
                            name: "그룹 추가",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text('게임 생성'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
