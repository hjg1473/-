import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/size_config.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentSeasonSelectScreen extends ConsumerWidget {
  const StudentSeasonSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 31 * SizeConfig.scales,
                  left: 64 * SizeConfig.scales,
                ),
                child: FilledButton.icon(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 16 * SizeConfig.scales,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: Text(
                    '돌아가기',
                    style: TextStyle(
                      fontSize: 16 * SizeConfig.scales,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * SizeConfig.scales,
                      vertical: 10 * SizeConfig.scales,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.7, 0.7),
              child: ClipOval(
                child: Material(
                  child: InkWell(
                    onTap: () {
                      ref.watch(statusProvider).setSeason(Season.SEASON1);
                      Navigator.of(context).pushNamed('/stud_main_screen');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 156 * SizeConfig.scales,
                      width: 156 * SizeConfig.scales,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(178, 0, 0, 0),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '시즌1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30 * SizeConfig.scales,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.1, -0.7),
              child: Container(
                height: 156 * SizeConfig.scales,
                width: 156 * SizeConfig.scales,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(178, 0, 0, 0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 60 * SizeConfig.scales,
                  color: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.5, 0.7),
              child: Container(
                height: 156 * SizeConfig.scales,
                width: 156 * SizeConfig.scales,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(178, 0, 0, 0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 60 * SizeConfig.scales,
                  color: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(1.1, -0.7),
              child: Container(
                height: 156 * SizeConfig.scales,
                width: 156 * SizeConfig.scales,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(178, 0, 0, 0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 60 * SizeConfig.scales,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
