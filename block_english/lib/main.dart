import 'package:block_english/screens/Auth/init_screen.dart';
import 'package:block_english/screens/Auth/login_screen.dart';
import 'package:block_english/screens/Auth/reg_select_role_screen.dart';
import 'package:block_english/screens/Auth/reg_student_screen.dart';
import 'package:block_english/screens/Auth/reg_super_screen.dart';
import 'package:block_english/screens/Super/super_main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Block English",
      initialRoute: '/init',
      routes: {
        '/init': (context) => const InitScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/reg_select_role_screen': (context) => const RegSelectRoleScreen(),
        '/reg_student_screen': (context) => const RegStudentScreen(),
        '/reg_super_screen': (context) => const RegSuperScreen(),
        '/super_main_screen': (context) => const SuperMainScreen(),
      },
    );
  }
}
