import 'package:block_english/screens/SuperScreens/super_game_setting_screen.dart';
import 'package:block_english/screens/SuperScreens/super_monitor_screen.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuperMainScreen extends StatefulWidget {
  const SuperMainScreen({super.key});

  @override
  State<SuperMainScreen> createState() => _SuperMainScreenState();
}

class _SuperMainScreenState extends State<SuperMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const SuperMonitorScreen(),
    const SuperGameSettingScreen(),
    Column(
      children: [
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
      ],
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 메인 위젯
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_rounded, size: 40),
            label: '모니터링',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_rounded, size: 40),
            label: '게임 관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, size: 40),
            label: '마이 페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFFa2a2a2),
        backgroundColor: const Color(0xFF565656),
        onTap: _onItemTapped,
      ),
    );
  }
}
