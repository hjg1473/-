import 'package:block_english/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            return FutureBuilder(
              future: ref.watch(authServiceProvider).postAuthAccess(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                snapshot.data!.fold(
                  (failure) {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => Navigator.of(context).pushNamedAndRemoveUntil(
                              '/init',
                              (Route<dynamic> route) => false,
                            ));
                    return const CircularProgressIndicator();
                  },
                  (accessresponse) {
                    switch (accessresponse.role) {
                      case 'student':
                        WidgetsBinding.instance.addPostFrameCallback((_) =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/std_main_screen',
                              (Route<dynamic> route) => false,
                            ));
                      case 'super':
                        WidgetsBinding.instance.addPostFrameCallback((_) =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/super_main_screen',
                              (Route<dynamic> route) => false,
                            ));
                    }
                  },
                );
                return const CircularProgressIndicator();
              },
            );
          },
        ),
      ),
    );
  }
}
