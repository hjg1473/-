import 'package:block_english/models/SuperModel/student_in_group_model.dart';
import 'package:block_english/screens/SuperScreens/super_group_setting_screen.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/student_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MonitorGroupScreen extends ConsumerStatefulWidget {
  const MonitorGroupScreen({
    super.key,
    required this.groupName,
    required this.detailText,
    required this.groupId,
  });

  final String groupName;
  final String detailText;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 64,
          vertical: 32,
        ).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                      '/super_monitor_screen',
                      ModalRoute.withName('/super_main_screen'),
                    ),
                    icon: SvgPicture.asset(
                      'assets/buttons/round_back_button.svg',
                      width: 48.r,
                      height: 48.r,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.groupName,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.detailText.isNotEmpty)
                        Text(
                          widget.detailText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    //TODO: 개인/그룹 바꾸는 버튼
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupSettingScreen(
                                        groupName: widget.groupName,
                                        detailText: widget.detailText,
                                        groupId: widget.groupId,
                                      )));
                        },
                        icon: SvgPicture.asset(
                          'assets/buttons/round_setting_button.svg',
                          width: 48.r,
                          height: 48.r,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
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
