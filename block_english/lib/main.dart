import 'package:block_english/screens/AuthScreens/init_screen.dart';
import 'package:block_english/screens/AuthScreens/login_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_select_role_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_student_screen.dart';
import 'package:block_english/screens/AuthScreens/reg_super_screen.dart';
import 'package:block_english/screens/StudentScreens/student_main_screen.dart';
import 'package:block_english/screens/SuperScreens/super_group_create_screen.dart';
import 'package:block_english/screens/SuperScreens/super_game_code_screen.dart';
import 'package:block_english/screens/SuperScreens/super_game_screen.dart';
import 'package:block_english/screens/SuperScreens/super_main_screen.dart';
import 'package:block_english/screens/loading_screen.dart';
import 'package:block_english/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color(0xFF6750A4),
        // ),
      ),
      title: "Block English",
      initialRoute: '/loading_screen',
      routes: {
        '/loading_screen': (context) => const LoadingScreen(),
        '/init': (context) => const InitScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/reg_select_role_screen': (context) => const RegSelectRoleScreen(),
        '/reg_student_screen': (context) => const RegStudentScreen(),
        '/reg_super_screen': (context) => const RegSuperFirstScreen(),
        '/std_main_screen': (context) => const StudentMainScreen(),
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
