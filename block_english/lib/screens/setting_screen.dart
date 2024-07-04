import 'package:block_english/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final storage = const FlutterSecureStorage();

  late String refreshToken;

  onLogoutPressed() async {
    refreshToken = await storage.read(key: 'refreshToken') ?? "";
    debugPrint('refreshToken : $refreshToken');
    int status = await AuthService.postAuthLogout(refreshToken);

    if (status == 200) {
      storage.delete(key: 'refreshToken');
      storage.delete(key: 'accessToken');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/init',
          (Route<dynamic> route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('다시해'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: onLogoutPressed,
          child: const Text("로그아웃"),
        ),
      ),
    );
  }
}
