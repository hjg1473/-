import 'package:block_english/models/MonitoringModel/group_monitoring_model.dart';
import 'package:block_english/models/MonitoringModel/group_progress_model.dart';
import 'package:block_english/models/MonitoringModel/user_summary_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/screens/SuperScreens/super_group_setting_screen.dart';
import 'package:block_english/screens/SuperScreens/super_monitor_student_screen.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/color.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/text_style.dart';
import 'package:block_english/widgets/ChartWidget/pie_chart_widget.dart';
import 'package:block_english/widgets/GroupWidget/group_progress_dropdown.dart';
import 'package:block_english/widgets/GroupWidget/student_in_group_button.dart';
import 'package:block_english/widgets/cool_drop_down_button.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

double horizontalPadding = 64.r;
double topPadding = 32.r;
double bottomPadding = 24.r;

class MonitorGroupScreen extends ConsumerStatefulWidget {
  const MonitorGroupScreen({
    super.key,
    required this.groupName,
    required this.detailText,
    required this.groupId,
    required this.onRefreshed,
  });

  final String groupName;
  final String detailText;
  final int groupId;
  final Function onRefreshed;

  @override
  ConsumerState<MonitorGroupScreen> createState() => _MonitorGroupScreenState();
}

class _MonitorGroupScreenState extends ConsumerState<MonitorGroupScreen> {
  int currentPage = 1;
  bool isTogglePressed = false;
  bool isLoading = true;
  GroupProgressModel? groupProgress;

  void waitForProgress() async {
    final response =
        await ref.watch(superServiceProvider).getGroupInfo(widget.groupId);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      groupProgress = data;
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    waitForProgress();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.purple[50],
            body: Stack(
              children: [
                Positioned(
                  top: 32.r,
                  left: 64.r,
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
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 27.r),
                    child: SizedBox(
                      height: 55.r,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.groupName,
                            style: textStyle22,
                          ),
                          if (widget.detailText.isNotEmpty)
                            Text(
                              widget.detailText,
                              style: textStyle14.copyWith(
                                color: const Color(0xFF888888),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.r,
                  right: 128.r,
                  child: SizedBox(
                    width: 123.r,
                    height: 32.r,
                    child: IconButton(
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            isTogglePressed = !isTogglePressed;
                          });
                        }
                      },
                      highlightColor: Colors.transparent,
                      icon: Image.asset(
                          isTogglePressed
                              ? 'assets/buttons/group_toggle_on_button.png'
                              : 'assets/buttons/group_toggle_off_button.png',
                          width: 123.r,
                          height: 32.r),
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 32.r,
                  right: 64.r,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupSettingScreen(
                                    groupName: widget.groupName,
                                    detailText: widget.detailText,
                                    groupId: widget.groupId,
                                    onRefreshed: widget.onRefreshed,
                                  )));
                    },
                    icon: SvgPicture.asset(
                      'assets/buttons/round_setting_button.svg',
                      width: 48.r,
                      height: 48.r,
                    ),
                  ),
                ),
                Positioned(
                  left: 64.r,
                  bottom: 25.r,
                  child: SizedBox(
                    width: 684.r,
                    height: 250.r,
                    child: isTogglePressed
                        ? Individual(
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                            info: groupProgress ?? GroupProgressModel(),
                          )
                        : Group(
                            groupId: widget.groupId,
                            info: groupProgress ?? GroupProgressModel()),
                  ),
                ),
              ],
            ),
          );
  }
}

class Group extends ConsumerStatefulWidget {
  const Group({
    super.key,
    required this.groupId,
    required this.info,
  });

  final int groupId;
  final GroupProgressModel info;

  @override
  ConsumerState<Group> createState() => _GroupState();
}

class _GroupState extends ConsumerState<Group> {
  List<String> seasonList = ['시즌 1', '시즌 2'];
  List<String> difficultyList = ['Basic', 'Expert'];
  List<String> stepList = [
    'Step 1',
    'Step 2',
    'Step 3',
    'Step 4',
    'Step 5',
  ];
  List<CoolDropdownItem<String>> seasonDropdownItems = [];
  final seasonDropdownController = DropdownController<String>();

  bool isLoading = true;
  GroupMonitoringModel? groupDetail;
  List<double> correctRate = [0, 0, 0];
  int bestLevel = -1;
  int basicBest = -1;
  int expertBest = -1;
  int seasonForStatics = 0;

  int season = 0;
  int level = 0;
  int step = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    waitForData();
  }

  void waitForData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    final response = await ref
        .watch(superServiceProvider)
        .postGroupMonitoring(widget.groupId);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      groupDetail = data;
      if (groupDetail!.studyInfo.isEmpty) {
        return;
      }
      debugPrint(groupDetail!.studyInfo[0].stepList.toString());
      StudyInfoModel last = groupDetail!.studyInfo.last;
      for (int i = 0; i < last.releasedLevel! + 1; i++) {
        correctRate[i] = (last.correctRateNormal![i] + last.correctRateAI![i]);
        if (bestLevel == -1 || correctRate[i] > correctRate[bestLevel]) {
          bestLevel = i;
        }
      }
      print(correctRate);
      // TODO: 시즌 리스트 업데이트, 시즌 별 데이터 업데이트
      for (int i = 0; i < groupDetail!.studyInfo.length; i++) {
        for (int j = 0; j < 3; j++) {
          double basicBestCorrectRate = 0;
          double expertBestCorrectRate = 0;
          if (groupDetail!.studyInfo[i].correctRateNormal![j] >
              basicBestCorrectRate) {
            basicBest = i;
            basicBestCorrectRate =
                groupDetail!.studyInfo[i].correctRateNormal![j];
          }
          if (groupDetail!.studyInfo[i].correctRateAI![j] >
              expertBestCorrectRate) {
            expertBest = i;
            basicBestCorrectRate = groupDetail!.studyInfo[i].correctRateAI![j];
          }
        }
      }
    });
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateProgress(int season, int level, int difficulty, int step) async {
    final response = await ref.watch(superServiceProvider).putGroupLevelUnlock(
          widget.groupId,
          'normal',
          season + 1,
          level,
          step,
        );

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('진도가 업데이트 되었습니다.'),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    season = widget.info.releasedSeason - 1;
    level = widget.info.releasedLevel;
    step = widget.info.releasedStep;

    for (var i = 0; i < season + 1; i++) {
      seasonDropdownItems.add(CoolDropdownItem<String>(
        label: seasonList[i],
        value: seasonList[i],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : groupDetail!.studyInfo.isEmpty
            ? const Center(child: Text('관리 중인 학생이 존재하지 않습니다'))
            : Stack(
                children: [
                  // group progress
                  Positioned(
                    top: 0,
                    left: 0.r,
                    child: Container(
                      width: 253.r,
                      height: 134.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.r,
                        vertical: 10.r,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '우리 반 진도',
                                style: textStyle11,
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  updateProgress(season, level, 0, step);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.r,
                                    vertical: 0.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryPurple[200],
                                    borderRadius: BorderRadius.circular(8).r,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16.r,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 7.r),
                          Row(
                            children: [
                              SizedBox(
                                width: 100.r,
                                height: 40.r,
                                child: GroupProgressDropdown(
                                  itemList: seasonList,
                                  initialItem: seasonList[season],
                                  onChanged: (value) {
                                    season = seasonList.indexOf(value!);
                                  },
                                ),
                              ),
                              SizedBox(width: 8.r),
                              SizedBox(
                                width: 113.r,
                                height: 40.r,
                                child: GroupProgressDropdown(
                                  itemList: groupDetail!
                                      .studyInfo[season].stepList![level],
                                  initialItem: groupDetail!
                                      .studyInfo[season].stepList![level][step],
                                  onChanged: (value) {
                                    step = groupDetail!
                                        .studyInfo[season].stepList![level]
                                        .indexOf(value!);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Padding(
                              //   padding: EdgeInsets.only(top: 3.3.r, bottom: 0),
                              //   child: Container(
                              //     width: 91.r,
                              //     height: 38.6.r,
                              //     padding: EdgeInsets.symmetric(
                              //       horizontal: 8.r,
                              //       vertical: 8.r,
                              //     ),
                              //     decoration: BoxDecoration(
                              //       color: primaryPurple[100],
                              //       borderRadius: BorderRadius.circular(8).r,
                              //     ),
                              //     child: Text('Basic', style: textStyle16),
                              //   ),
                              // ),
                              // SizedBox(width: 8.r),
                              SizedBox(
                                width: 113.r,
                                height: 40.r,
                                child: GroupProgressDropdown(
                                  itemList: levelList,
                                  initialItem: levelList[level],
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        level = levelList.indexOf(value!);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // group size
                  Positioned(
                    top: 150.r,
                    left: 0,
                    child: Container(
                      width: 253.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.r,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '우리 반 인원',
                            style: textStyle11,
                          ),
                          Text(
                            '${groupDetail?.peoples}명',
                            style: textStyle18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // group creation date
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 253.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.r,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '우리 반 생성일',
                            style: textStyle11,
                          ),
                          Text(
                            groupDetail != null
                                ? '20${groupDetail?.created}'
                                : '',
                            style: textStyle18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // correct rate
                  Positioned(
                    top: 0,
                    left: 269.r,
                    child: Container(
                      width: 247.r,
                      height: 250.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 23.r,
                        vertical: 23.r,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PieChartWidget(
                            width: 111.86.r,
                            height: 111.86.r,
                            data: correctRate[bestLevel] == 0
                                ? [100, 0, 0]
                                : correctRate,
                          ),
                          const Spacer(flex: 2),
                          Text(
                            '이 문제를 잘했어요!',
                            style: textStyle18,
                          ),
                          const Spacer(flex: 1),
                          Text(
                            '우리 반은 ${levelList[bestLevel]}에서 정답률이 가장 높아요.',
                            style: textStyle14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 77.r,
                    right: 263.r,
                    child: SvgPicture.asset(
                      'assets/images/connecting_line.svg',
                      width: 35.r,
                    ),
                  ),
                  Positioned(
                    top: 67.5.r,
                    right: 178.r,
                    child: Container(
                      width: 79.r,
                      height: 26.r,
                      decoration: BoxDecoration(
                        color: primaryPurple[500],
                        borderRadius: BorderRadius.circular(20).r,
                      ),
                      child: Center(
                        child: Text(
                          correctRate[bestLevel] == 0
                              ? '기록 없음'
                              : levelList[bestLevel],
                          style: textStyle14.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 102.r,
                    right: 187.r,
                    child: Text(
                      '${correctRate[bestLevel].toInt()}%',
                      style: textStyle14,
                    ),
                  ),
                  // best level
                  Positioned(
                    top: 47.r,
                    right: 0,
                    child: Container(
                      width: 153.r,
                      height: 118.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 21.r,
                        vertical: 13.5.r,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic BEST',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                              color: const Color(0xFF878787),
                            ),
                          ),
                          const Spacer(flex: 5),
                          Text(
                            basicBest == -1 ? '데이터 없음' : levelList[basicBest],
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17.sp,
                              color: primaryPurple[500],
                            ),
                          ),
                          const Spacer(flex: 12),
                          Text(
                            'Expert BEST',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                              color: const Color(0xFF878787),
                            ),
                          ),
                          const Spacer(flex: 5),
                          Text(
                            expertBest == -1 ? '데이터 없음' : levelList[expertBest],
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17.sp,
                              color: primaryPurple[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // weakest part
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 153.r,
                      height: 70.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 21.r,
                        vertical: 13.r,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '가장 약한 부분은?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                              color: const Color(0xFF878787),
                            ),
                          ),
                          Text(
                            groupDetail != null
                                ? '${wrongToString(groupDetail!.weakest)} 오류'
                                : '데이터 없음',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17.sp,
                              color: primaryPurple[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // select season for statics
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CoolDropDownButton(
                      controller: seasonDropdownController,
                      dropdownList: seasonDropdownItems,
                      defaultItem: seasonDropdownItems[seasonForStatics],
                      onChange: (value) async {
                        if (seasonDropdownController.isError) {
                          await seasonDropdownController.resetError();
                        }
                        if (seasonForStatics != value) {
                          seasonForStatics = seasonList.indexOf(value);
                          seasonDropdownController.close();
                          waitForData();
                        }
                      },
                      width: 153.r,
                      height: 36.r,
                      backgroundColor: Colors.white,
                      primaryColor: primaryPurple[500]!,
                      textStyle: textStyle14,
                    ),
                  ),
                ],
              );
  }
}

class Individual extends ConsumerStatefulWidget {
  const Individual({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.info,
  });

  final int groupId;
  final String groupName;
  final GroupProgressModel info;

  @override
  ConsumerState<Individual> createState() => _IndividualState();
}

class _IndividualState extends ConsumerState<Individual> {
  String error = '';
  List<StudentsInfoModel> students = [];
  late UserSummaryModel summary;
  bool isLoading = true;

  List<String> seasonList = ['시즌 1', '시즌 2'];
  List<CoolDropdownItem<String>> seasonDropdownItems = [];
  final seasonDropdownController = DropdownController<String>();
  int seasonForStatics = 0;
  int season = 0;
  int selectedStudent = 0;
  List<double> correctRate = [0, 0, 0];
  int bestLevel = -1;
  int basicBest = -1;
  int expertBest = -1;

  void waitForStudents() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    var response =
        await ref.watch(superServiceProvider).getStudentInGroup(widget.groupId);

    response.fold(
      (failure) {
        error = failure.detail;
      },
      (studentList) {
        students = studentList;
        if (students.isEmpty) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          getSummary();
        }
      },
    );
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
    season = widget.info.releasedSeason - 1;

    for (var i = 0; i < season + 1; i++) {
      seasonDropdownItems.add(CoolDropdownItem<String>(
        label: seasonList[i],
        value: seasonList[i],
      ));
    }
  }

  void getSummary() async {
    var response = await ref
        .watch(superServiceProvider)
        .postUserMonitoringSummary(
            students[selectedStudent].id, seasonForStatics + 1);

    response.fold(
      (failure) {
        error = failure.detail;
      },
      (data) {
        summary = data;
        summary.weakParts.topRates = summary.weakParts.getTopNRates(3);
        StudyInfoModel rates = summary.rates;
        print(rates.releasedLevel);
        for (int i = 0; i < rates.releasedLevel! + 1; i++) {
          correctRate[i] =
              (rates.correctRateNormal![i] + rates.correctRateAI![i]);
          if (bestLevel == -1 || correctRate[i] > correctRate[bestLevel]) {
            bestLevel = i;
          }
        }
        print(correctRate);

        for (int i = 0; i < 3; i++) {
          double basicBestCorrectRate = 0;
          double expertBestCorrectRate = 0;
          if (rates.correctRateNormal![i] > basicBestCorrectRate) {
            basicBest = i;
            basicBestCorrectRate = rates.correctRateNormal![i];
          }
          if (rates.correctRateAI![i] > expertBestCorrectRate) {
            expertBest = i;
            basicBestCorrectRate = rates.correctRateAI![i];
          }
        }
      },
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : error.isNotEmpty
            ? Center(child: Text(error))
            : students.isEmpty
                ? const Center(child: Text('관리 중인 학생이 존재하지 않습니다'))
                : Stack(
                    children: [
                      // students list
                      Positioned(
                        left: 0,
                        top: 0,
                        child: SizedBox(
                          width: 140.r,
                          height: 250.r,
                          child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: students.length,
                            itemBuilder: (BuildContext context, int index) {
                              var student = students[index];
                              return StudentInGroupButton(
                                name: student.name,
                                isSelected: selectedStudent == index,
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      selectedStudent = index;
                                      getSummary();
                                    });
                                  }
                                },
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 8.r),
                          ),
                        ),
                      ),
                      // learning analysis
                      Positioned(
                        top: 0,
                        left: 156.r,
                        child: Container(
                          width: 346.r,
                          height: 250.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8).r,
                          ),
                          child: Stack(
                            children: [
                              // correct rate
                              Positioned(
                                top: 43.r,
                                left: 29.5.r,
                                child: PieChartWidget(
                                  width: 110.r,
                                  height: 110.r,
                                  data: correctRate,
                                ),
                              ),
                              Positioned(
                                top: 32.r,
                                left: 104.r,
                                child: SvgPicture.asset(
                                  'assets/images/angled_connecting_line.svg',
                                  height: 28.r,
                                ),
                              ),
                              Positioned(
                                top: 21.r,
                                left: 140.r,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${correctRate[bestLevel].toInt()}%',
                                      style: textStyle14,
                                    ),
                                    SizedBox(width: 8.r),
                                    Container(
                                      width: 79.r,
                                      height: 26.r,
                                      decoration: BoxDecoration(
                                        color: primaryPurple[500],
                                        borderRadius:
                                            BorderRadius.circular(20).r,
                                      ),
                                      child: Center(
                                        child: Text(
                                          levelList[bestLevel],
                                          style: textStyle14.copyWith(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 97.r,
                                right: 29.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '이 문제를 잘했어요!',
                                      style: textStyle18,
                                    ),
                                    SizedBox(height: 8.r),
                                    Text(
                                      '지금까지 ${levelList[bestLevel]}에서의\n정답률이 가장 높아요.',
                                      style: textStyle14,
                                    ),
                                  ],
                                ),
                              ),
                              // basic best
                              Positioned(
                                left: 29.5.r,
                                bottom: 20.r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 118.r,
                                      height: 26.r,
                                      decoration: BoxDecoration(
                                        color: primaryPurple[500],
                                        borderRadius:
                                            BorderRadius.circular(20).r,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Basic BEST',
                                          style: textStyle14.copyWith(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.r),
                                    Text(
                                      basicBest == -1
                                          ? '데이터 없음'
                                          : levelList[basicBest],
                                      style: textStyle14,
                                    ),
                                  ],
                                ),
                              ),
                              // dividing line
                              Positioned(
                                top: 176.r,
                                left: 164.5.r,
                                bottom: 20.r,
                                child: VerticalDivider(
                                  color: const Color(0xFFD9D9D9),
                                  thickness: 1.r,
                                ),
                              ),
                              // expert best
                              Positioned(
                                right: 29.5,
                                bottom: 20.r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 118.r,
                                      height: 26.r,
                                      decoration: BoxDecoration(
                                        color: primaryPurple[500],
                                        borderRadius:
                                            BorderRadius.circular(20).r,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Expert BEST',
                                          style: textStyle14.copyWith(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.r),
                                    Text(
                                      expertBest == -1
                                          ? '데이터 없음'
                                          : levelList[expertBest],
                                      style: textStyle14,
                                    ),
                                  ],
                                ),
                              ),
                              // detail button
                              Positioned(
                                top: 20.r,
                                right: 20.r,
                                child: SizedBox(
                                  width: 15.r,
                                  height: 24.r,
                                  child: IconButton(
                                    onPressed: () async {
                                      final result = await Navigator.of(context,
                                              rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MonitorStudentScreen(
                                            studentId:
                                                students[selectedStudent].id,
                                            studentName:
                                                students[selectedStudent].name,
                                            groupName: widget.groupName,
                                            initialPage: 1,
                                          ),
                                        ),
                                      );
                                      if (result != null) {
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 15.r,
                                      color: const Color(0xFFC3C3C3),
                                    ),
                                    style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          EdgeInsets.zero),
                                    ),
                                    highlightColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // select season for statics
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CoolDropDownButton(
                          controller: seasonDropdownController,
                          dropdownList: seasonDropdownItems,
                          defaultItem: seasonDropdownItems[seasonForStatics],
                          onChange: (value) async {
                            if (seasonDropdownController.isError) {
                              await seasonDropdownController.resetError();
                            }
                            if (seasonForStatics != value) {
                              seasonForStatics = seasonList.indexOf(value);
                              seasonDropdownController.close();
                              waitForStudents();
                            }
                          },
                          width: 166.r,
                          height: 40.r,
                          backgroundColor: Colors.white,
                          primaryColor: primaryPurple[500]!,
                          textStyle: textStyle14,
                        ),
                      ),
                      // study time
                      Positioned(
                        top: 52.r,
                        right: 0,
                        child: Container(
                          width: 166.r,
                          height: 46.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8).r,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 20.r,
                                top: 10.r,
                                child: Icon(
                                  Icons.access_time_filled,
                                  color: primaryPurple[500],
                                  size: 26.r,
                                ),
                              ),
                              Positioned(
                                top: 7.r,
                                left: 62.r,
                                child: SizedBox(
                                  width: 60.r,
                                  child: Text(
                                    '${summary.totalStudyTime}시간',
                                    textAlign: TextAlign.center,
                                    style: textStyle14.copyWith(
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 7.r,
                                left: 62.r,
                                child: SizedBox(
                                  width: 60.r,
                                  child: Text(
                                    '총 학습 시간',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9.sp,
                                      color: const Color(0xFFB2B2B2),
                                    ),
                                  ),
                                ),
                              ),
                              // detail button
                              Positioned(
                                top: 11.r,
                                right: 12.r,
                                child: SizedBox(
                                  width: 15.r,
                                  height: 24.r,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MonitorStudentScreen(
                                            studentId:
                                                students[selectedStudent].id,
                                            studentName:
                                                students[selectedStudent].name,
                                            groupName: widget.groupName,
                                            initialPage: 3,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 15.r,
                                      color: const Color(0xFFC3C3C3),
                                    ),
                                    style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          EdgeInsets.zero),
                                    ),
                                    highlightColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // incorrect
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 166.r,
                          height: 142.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8).r,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 15.r,
                                left: 16.r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '가장 약한 부분은?',
                                      style: textStyle11.copyWith(
                                        color: const Color(0xFF878787),
                                      ),
                                    ),
                                    Text(
                                      '${wrongToString(summary.weakParts.topRates[0].key)} 오류',
                                      style: textStyle18.copyWith(
                                        color: primaryPurple[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 15.r,
                                left: 16.r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wrongToString(
                                          summary.weakParts.topRates[0].key),
                                      style: textStyle11,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      wrongToString(
                                          summary.weakParts.topRates[1].key),
                                      style: textStyle11,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      wrongToString(
                                          summary.weakParts.topRates[2].key),
                                      style: textStyle11,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 15.r,
                                left: 84.r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${(summary.weakParts.topRates[0].value * 100).toInt()}%',
                                      style: textStyle11,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${(summary.weakParts.topRates[1].value * 100).toInt()}%',
                                      style: textStyle11,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${(summary.weakParts.topRates[2].value * 100).toInt()}%',
                                      style: textStyle11,
                                    ),
                                  ],
                                ),
                              ),
                              // detail button
                              Positioned(
                                top: 12.r,
                                right: 12.r,
                                child: SizedBox(
                                  width: 15.r,
                                  height: 24.r,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MonitorStudentScreen(
                                            studentId:
                                                students[selectedStudent].id,
                                            studentName:
                                                students[selectedStudent].name,
                                            groupName: widget.groupName,
                                            initialPage: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 15.r,
                                      color: const Color(0xFFC3C3C3),
                                    ),
                                    style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          EdgeInsets.zero),
                                    ),
                                    highlightColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
  }
}
