import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/student_profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuperMyPage extends StatelessWidget {
  const SuperMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이 페이지',
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/setting_screen');
              }),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(children: [
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
                return StudentProfileCard(name: text);
              },
            );
          },
        ),
      ]),
    );
  }
}
