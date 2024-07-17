import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  onLogoutPressed() async {
    final storage = ref.watch(secureStorageProvider);
    final result = await ref
        .watch(authServiceProvider)
        .postAuthLogout(await storage.readRefreshToken() ?? "");

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('애플리케이션을 재시작해 주세요'),
            ),
          );
        }
      },
      (response) {
        if (response.statusCode == 200) {
          storage.removeTokens();
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
      },
    );
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
