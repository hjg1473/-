import 'package:block_english/models/refresh_response_model.dart';
import 'package:block_english/models/student_info_model.dart';
import 'package:block_english/services/auth_service.dart';
import 'package:block_english/services/student_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  late String _name;
  late String _age;
  bool isFetched = false;

  fetchStudentInfo() async {
    final accessToken = await storage.read(key: ACCESS_TOKEN);
    StudentInfoModel studentInfoModel;

    try {
      if (accessToken == null) {
        throw Exception();
      }
      studentInfoModel = await StudentService.getStudentInfo(accessToken);
    } on Exception catch (e) {
      final refreshToken = await storage.read(key: REFRESH_TOKEN);

      try {
        if (refreshToken == null) {
          return "";
        }

        RefreshResponseModel refreshResponseModel =
            await AuthService.postAuthRefresh(refreshToken);

        await storage.write(
            key: "accessToken", value: refreshResponseModel.accessToken);

        studentInfoModel = await StudentService.getStudentInfo(
            refreshResponseModel.accessToken);
      } on Exception catch (e) {
        debugPrint("RefreshToken Validation Error: $e");
        return Error();
      }
    }

    debugPrint("name : ${studentInfoModel.name}");
    debugPrint("age : ${studentInfoModel.age}");

    setState(() {
      _name = studentInfoModel.name;
      _age = studentInfoModel.age;
      isFetched = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isFetched
            ? Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    ProfileCard(
                      name: _name,
                      age: _age,
                      isStudent: true,
                    )
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
