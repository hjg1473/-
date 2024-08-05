import 'package:block_english/screens/AuthScreens/login_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_pw_question_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_select_role_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_student_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_super_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_super_type_screen.dart';
import 'package:block_english/screens/StudentScreens/student_main_screen.dart';
import 'package:block_english/screens/StudentScreens/student_mode_select_screen.dart';
import 'package:block_english/screens/StudentScreens/student_season_select_screen.dart';
import 'package:block_english/screens/SuperScreens/super_group_create_screen.dart';
import 'package:block_english/screens/SuperScreens/super_game_code_screen.dart';
import 'package:block_english/screens/SuperScreens/super_game_screen.dart';
import 'package:block_english/screens/SuperScreens/super_main_screen.dart';
import 'package:block_english/screens/loading_screen.dart';
import 'package:block_english/screens/setting_screen.dart';
import 'package:block_english/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    SizeConfig().init(context);

    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
      ),
      title: "Block English",
      initialRoute: '/loading_screen',
      routes: {
        '/loading_screen': (context) => const LoadingScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/reg_select_role_screen': (context) => const RegSelectRoleScreen(),
        '/reg_super_type_screen': (context) => const RegSuperTypeScreen(),
        '/reg_student_screen': (context) => const RegStudentScreen(),
        '/reg_super_screen': (context) => const RegSuperScreen(),
        '/reg_pw_question_screen': (context) => const RegPwQuestionScreen(),
        '/stud_mode_select_screen': (context) =>
            const StudentModeSelectScreen(),
        '/stud_season_select_screen': (context) =>
            const StudentSeasonSelectScreen(),
        '/stud_main_screen': (context) => const StudentMainScreen(),
        '/super_main_screen': (context) => const SuperMainScreen(),
        '/super_group_create_screen': (context) =>
            const SuperGroupCreateScreen(),
        '/super_game_code_screen': (context) => const SuperGameCodeScreen(),
        '/super_game_screen': (context) => const SuperGameScreen(),
        '/setting_screen': (context) => const SettingScreen(),
      },
    );
  }
}
