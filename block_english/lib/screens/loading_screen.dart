import 'package:block_english/services/auth_service.dart';
import 'package:block_english/services/student_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  loginWithToken() async {
    final result = await ref.watch(authServiceProvider).postAuthAccess();

    result.fold((failure) {
      debugPrint('dd');
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login_screen',
        (Route<dynamic> route) => false,
      );
    }, (accessResponse) async {
      if (accessResponse.role == UserType.student.name) {
        final response =
            await ref.watch(studentServiceProvider).getSeasonInfo();
        response.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('시즌 조회 ${failure.statusCode}: ${failure.detail}'),
              ),
            );
          },
          (seasons) {
            ref.watch(statusProvider).setAvailableSeason(seasons);
            if (seasons.isEmpty) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/stud_available_season_screen',
                (Route<dynamic> route) => false,
              );
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/stud_mode_select_screen',
                (Route<dynamic> route) => false,
              );
            }
          },
        );
      } else if (accessResponse.role == UserType.teacher.name ||
          accessResponse.role == UserType.parent.name) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/super_main_screen',
          (Route<dynamic> route) => false,
        );
      } else {
        //TODO: show dialog and exit app
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/setting_screen',
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginWithToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
