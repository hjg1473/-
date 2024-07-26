import 'package:block_english/models/SuperModel/student_in_group_model.dart';
import 'package:block_english/screens/SuperScreens/super_group_setting_screen.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/student_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonitorGroupScreen extends ConsumerStatefulWidget {
  const MonitorGroupScreen({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  final String groupName;
  final int groupId;

  @override
  ConsumerState<MonitorGroupScreen> createState() => _MonitorGroupScreenState();
}

class _MonitorGroupScreenState extends ConsumerState<MonitorGroupScreen> {
  String error = '';
  List<StudentInGroupModel> students = [];
  bool isLoading = true;

  void waitForStudents() async {
    var response =
        await ref.watch(superServiceProvider).getStudentInGroup(widget.groupId);

    response.fold(
      (failure) {
        error = failure.detail;
      },
      (studentList) {
        students = studentList;
      },
    );
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    waitForStudents();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.groupName,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GroupSettingScreen(
                      groupName: widget.groupName,
                      groupId: widget.groupId,
                    ),
                  ),
                );
              },
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: error.isEmpty
                        ? students.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '관리 중인 학생이 존재하지 않습니다',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      '그룹 설정 버튼을 눌러',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '학생을 추가하세요',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.vertical,
                                itemCount: students.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var student = students[index];
                                  return StudentButton(
                                    name: student.name,
                                    studentId: student.id,
                                    groupId: widget.groupId,
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 20),
                              )
                        : Center(child: Text(error))),
          ],
        ),
      ),
    );
  }
}
