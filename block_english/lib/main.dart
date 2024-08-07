import 'package:block_english/screens/AuthScreens/login_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_pw_question_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_select_role_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_get_info_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_super_type_screen.dart';
import 'package:block_english/screens/UserScreens/user_change_password_screen.dart';
import 'package:block_english/screens/StudentScreens/student_main_screen.dart';
import 'package:block_english/screens/StudentScreens/student_mode_select_screen.dart';
import 'package:block_english/screens/StudentScreens/student_profile_screen.dart';
import 'package:block_english/screens/StudentScreens/student_season_select_screen.dart';
import 'package:block_english/screens/StudentScreens/student_step_select_screen.dart';
import 'package:block_english/screens/SuperScreens/super_group_create_screen.dart';
import 'package:block_english/screens/SuperScreens/super_game_code_screen.dart';
import 'package:block_english/screens/SuperScreens/super_game_screen.dart';
import 'package:block_english/screens/SuperScreens/super_main_screen.dart';
import 'package:block_english/screens/SuperScreens/super_monitor_screen.dart';
import 'package:block_english/screens/loading_screen.dart';
import 'package:block_english/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return ScreenUtilInit(
      designSize: const Size(812, 375),
      //minTextAdapt: true,
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
          ),
          fontFamily: 'NanumSquareRound',
        ),
        title: "Block English",
        initialRoute: '/loading_screen',
        routes: {
          '/loading_screen': (context) => const LoadingScreen(),
          '/login_screen': (context) => const LoginScreen(),
          '/reg_select_role_screen': (context) => const RegSelectRoleScreen(),
          '/reg_super_type_screen': (context) => const RegSuperTypeScreen(),
          '/reg_get_info_screen': (context) => const RegGetInfoScreen(),
          '/reg_pw_question_screen': (context) => const RegPwQuestionScreen(),
          '/user_change_password_screen': (context) =>
              const UserChangePasswordScreen(),
          '/stud_mode_select_screen': (context) =>
              const StudentModeSelectScreen(),
          '/stud_season_select_screen': (context) =>
              const StudentSeasonSelectScreen(),
          '/stud_main_screen': (context) => const StudentMainScreen(),
          '/stud_step_select_screen': (context) =>
              const StudentStepSelectScreen(),
          '/stud_profile_screen': (context) => const StudentProfileScreen(),
          '/super_main_screen': (context) => const SuperMainScreen(),
          '/super_monitor_screen': (context) => const SuperMonitorScreen(),
          '/super_group_create_screen': (context) =>
              const SuperGroupCreateScreen(),
          '/super_game_code_screen': (context) => const SuperGameCodeScreen(),
          '/super_game_screen': (context) => const SuperGameScreen(),
          '/setting_screen': (context) => const SettingScreen(),
        },
      ),
    );
  }
}
