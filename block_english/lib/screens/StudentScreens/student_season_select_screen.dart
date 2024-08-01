import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/device_scale.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentSeasonSelectScreen extends ConsumerWidget {
  const StudentSeasonSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                top: 20.0 * DeviceScale.scaleHeight(context),
                left: 50.0 * DeviceScale.scaleWidth(context),
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0 * DeviceScale.scaleHeight(context),
                    horizontal: 30.0 * DeviceScale.scaleWidth(context),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                label: Text(
                  '돌아가기',
                  style: TextStyle(
                    fontSize: 16 * DeviceScale.scaleHeight(context),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                    height: 156 * DeviceScale.scaleHeight(context),
                    width: 156 * DeviceScale.scaleHeight(context),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(178, 0, 0, 0),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '시즌1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
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
              height: 156 * DeviceScale.scaleHeight(context),
              width: 156 * DeviceScale.scaleHeight(context),
              decoration: const BoxDecoration(
                color: Color.fromARGB(178, 0, 0, 0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.question_mark_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.5, 0.7),
            child: Container(
              height: 156 * DeviceScale.scaleHeight(context),
              width: 156 * DeviceScale.scaleHeight(context),
              decoration: const BoxDecoration(
                color: Color.fromARGB(178, 0, 0, 0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.question_mark_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1.1, -0.7),
            child: Container(
              height: 156 * DeviceScale.scaleHeight(context),
              width: 156 * DeviceScale.scaleHeight(context),
              decoration: const BoxDecoration(
                color: Color.fromARGB(178, 0, 0, 0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.question_mark_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
