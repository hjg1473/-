import 'package:block_english/models/access_reponse_model.dart';
import 'package:block_english/models/refresh_response_model.dart';
import 'package:block_english/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/access_reponse_model.dart';
import '../services/auth_service.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  final storage = const FlutterSecureStorage();

  Future<String> checkToken() async {
    await storage.delete(key: "accessToken");

    final accessToken = await storage.read(key: "accessToken");
    try {
      if (accessToken == null) {
        throw Exception();
      }
      AccessReponseModel accessReponseModel =
          await AuthService.postAuthAccess(accessToken);

      return accessReponseModel.role;
    } on Exception catch (e) {
      debugPrint("Access Token Validation error: $e");
      // grant access token with refresh token and retry
      final refreshToken = await storage.read(key: "refreshToken");

      try {
        if (refreshToken == null) {
          return "";
        }

        RefreshResponseModel refreshResponseModel =
            await AuthService.postAuthRefresh(refreshToken);

        await storage.write(
            key: "accessToken", value: refreshResponseModel.accessToken);

        AccessReponseModel accessReponseModel =
            await AuthService.postAuthAccess(refreshResponseModel.accessToken);

        return accessReponseModel.role;
      } on Exception catch (e) {
        debugPrint("RefreshToken Validation Error: $e");
        return "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: checkToken(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == false) {
              return const CircularProgressIndicator();
            } else if (snapshot.data.toString() == "student") {
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => Navigator.of(context).pushNamedAndRemoveUntil(
                        '/std_main_screen',
                        (Route<dynamic> route) => false,
                      ));
              return const CircularProgressIndicator();
            } else if (snapshot.data.toString() == "super") {
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => Navigator.of(context).pushNamedAndRemoveUntil(
                        '/super_main_screen',
                        (Route<dynamic> route) => false,
                      ));
              return const CircularProgressIndicator();
            } else {
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => Navigator.of(context).pushNamedAndRemoveUntil(
                        '/init',
                        (Route<dynamic> route) => false,
                      ));
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
