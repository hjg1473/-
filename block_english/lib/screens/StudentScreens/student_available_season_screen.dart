import 'package:block_english/services/student_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/status.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentAvailableSeasonScreen extends ConsumerStatefulWidget {
  const StudentAvailableSeasonScreen({super.key});

  @override
  ConsumerState<StudentAvailableSeasonScreen> createState() =>
      _StudentAvailableSeasonScreenState();
}

class _StudentAvailableSeasonScreenState
    extends ConsumerState<StudentAvailableSeasonScreen> {
  List<int> seasons = [];
  bool season1Selected = false;

  onPressed() async {
    if (season1Selected) {
      seasons.add(1);
    } else {
      seasons.remove(1);
    }

    if (seasons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('시즌을 선택해 주세요!'),
        ),
      );
      return;
    }

    final response =
        await ref.read(studentServiceProvider).putUpdateSeason(seasons);
    response.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${failure.statusCode} : ${failure.detail}'),
          ),
        );
      },
      (success) {
        //TODO: set season1 status
        ref.watch(statusProvider).setAvailableSeason(seasons);
        ref.watch(statusProvider).setStudentStatus(
              Season.SEASON1,
              ReleaseStatus(0, 0),
            );
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/stud_mode_select_screen',
            (Route<dynamic> route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFFAFC),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 32.r),
              child: Text(
                '가지고 있는 블록의 시즌을 모두 선택해 주세요!',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: 1.sw,
              child: SquareButton(
                text: '계속하기',
                onPressed: onPressed,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                const Spacer(flex: 4),
                IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    setState(() {
                      season1Selected = !season1Selected;
                    });
                  },
                  icon: Image.asset(
                    season1Selected
                        ? 'assets/buttons/season_1_selected_large.png'
                        : 'assets/buttons/season_1_unselected_large.png',
                    width: 465.r,
                    height: 60.r,
                  ),
                ),
                IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: null,
                  icon: Image.asset(
                    'assets/buttons/season_2_unselected_large.png',
                    width: 465.r,
                    height: 60.r,
                  ),
                ),
                const Spacer(flex: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
