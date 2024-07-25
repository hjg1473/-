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
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GroupSettingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? const Text('Loading...')
                : Expanded(
                    child: error.isEmpty
                        ? ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: students.length,
                            itemBuilder: (BuildContext context, int index) {
                              var student = students[index];
                              return StudentButton(
                                name: student.name,
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