import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:block_english/models/MonitoringModel/group_monitoring_model.dart';
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
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String group = '/';
const String individual = '/individual';

double horizontalPadding = 64.r;
double topPadding = 32.r;
double bottomPadding = 24.r;

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required super.builder});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
              .animate(animation),
      child: child,
    );
  }
}

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
  final _navigatorKey = GlobalKey<NavigatorState>();
  int currentPage = 1;
  bool isTogglePressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: Stack(
        children: [
          Positioned(
            top: 32.r,
            left: 64.r,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
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
                  setState(() {
                    isTogglePressed = !isTogglePressed;
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _navigatorKey.currentState!.pop();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _navigatorKey.currentState!
                          .pushNamed(isTogglePressed ? individual : group);
                    });
                  });
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
            bottom: 24.r,
            child: SizedBox(
              width: 1.sw,
              height: 250.r,
              child: Navigator(
                key: _navigatorKey,
                initialRoute: group,
                onGenerateRoute: (settings) {
                  return CustomRoute(
                    builder: (context) {
                      switch (settings.name) {
                        case group:
                          return Group(groupId: widget.groupId);
                        case individual:
                          return Individual(
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                          );
                        default:
                          return Group(groupId: widget.groupId);
                      }
                    },
                  );
                },
              ),
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
  });

  final int groupId;

  @override
  ConsumerState<Group> createState() => _GroupState();
}

class _GroupState extends ConsumerState<Group> {
  List<String> seasonList = ['시즌 1', '시즌 2'];
  List<CoolDropdownItem<String>> seasonDropdownItems = [];
  final seasonDropdownController = DropdownController<String>();

  bool isLoading = true;
  GroupMonitoringModel? groupDetail;
  List<double> forCorrectRate = [];
  int basicBest = -1;
  int expertBest = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    waitForData();
  }

  waitForData() async {
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
      StudyInfoModel last = groupDetail!.studyInfo.last;
      for (int i = 0; i < last.releasedLevel!; i++) {
        forCorrectRate.add(last.correctRateNormal![i] + last.correctRateAI![i]);
      }
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

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < seasonList.length; i++) {
      seasonDropdownItems.add(CoolDropdownItem<String>(
        label: seasonList[i],
        value: seasonList[i],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> difficultyList = ['Basic', 'Expert'];
    List<String> stepList = [
      'Step 1',
      'Step 2',
      'Step 3',
      'Step 4',
      'Step 5',
    ];
    int season = 0;
    int level = 0;
    int difficulty = 0;
    int step = 0;

    int seasonForStatics = 0;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              // group progress
              Positioned(
                top: 0,
                left: 64.r,
                child: Container(
                  width: 253.r,
                  height: 134.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8).r,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 12.r,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '우리 반 진도',
                        style: textStyle11,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          SizedBox(
                            width: 92.r,
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
                              itemList: levelList,
                              initialItem: levelList[level],
                              onChanged: (value) {
                                level = levelList.indexOf(value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.r),
                      Row(
                        children: [
                          SizedBox(
                            width: 92.r,
                            height: 40.r,
                            child: GroupProgressDropdown(
                                itemList: difficultyList,
                                initialItem: difficultyList[difficulty],
                                onChanged: (value) {
                                  difficulty = difficultyList.indexOf(value!);
                                }),
                          ),
                          SizedBox(width: 8.r),
                          SizedBox(
                            width: 100.r,
                            height: 40.r,
                            child: GroupProgressDropdown(
                              itemList: stepList,
                              initialItem: stepList[step],
                              onChanged: (value) {
                                step = stepList.indexOf(value!);
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
                left: 64.r,
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
                left: 64.r,
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
                        groupDetail != null ? '20${groupDetail?.created}' : '',
                        style: textStyle18,
                      ),
                    ],
                  ),
                ),
              ),
              // error rate
              Positioned(
                top: 0,
                left: 333.r,
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
                      ),
                      SizedBox(height: 17.r),
                      Text(
                        '이 문제를 잘했어요!',
                        style: textStyle18,
                      ),
                      SizedBox(height: 9.r),
                      Text(
                        '우리 반은 어순과 격에서 오답율이\n가장 적어요.',
                        style: textStyle14,
                      ),
                    ],
                  ),
                ),
              ),
              // // best level
              Positioned(
                top: 54.r,
                right: 64.r,
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
                right: 64.r,
                child: Container(
                  width: 153.r,
                  height: 70.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8).r,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 21.r,
                    vertical: 14.r,
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
                right: 64.r,
                child: CoolDropdown<String>(
                  dropdownList: seasonDropdownItems,
                  controller: seasonDropdownController,
                  defaultItem: seasonDropdownItems[seasonForStatics],
                  onChange: (value) async {
                    if (seasonDropdownController.isError) {
                      await seasonDropdownController.resetError();
                    }
                    seasonForStatics = seasonList.indexOf(value);
                  },
                  resultOptions: ResultOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 15).r,
                    width: 153.r,
                    height: 36.r,
                    icon: SizedBox(
                      width: 13.31.r,
                      height: 10.r,
                      child: const CustomPaint(
                        painter: DropdownArrowPainter(color: Colors.black),
                      ),
                    ),
                    render: ResultRender.all,
                    isMarquee: false,
                  ),
                  dropdownOptions: DropdownOptions(
                    top: 0,
                    width: 153.r,
                    borderSide: const BorderSide(width: 0, color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 15).r,
                    align: DropdownAlign.center,
                    animationType: DropdownAnimationType.size,
                  ),
                  dropdownTriangleOptions: const DropdownTriangleOptions(
                    width: 0,
                    height: 0,
                  ),
                  dropdownItemOptions: DropdownItemOptions(
                    isMarquee: true,
                    mainAxisAlignment: MainAxisAlignment.start,
                    render: DropdownItemRender.all,
                    height: 36.r,
                  ),
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
  });

  final int groupId;
  final String groupName;

  @override
  ConsumerState<Individual> createState() => _IndividualState();
}

class _IndividualState extends ConsumerState<Individual> {
  String error = '';
  List<StudentsInfoModel> students = [];
  late UserSummaryModel summary;
  bool isLoading = true;

  List<String> seasonList = ['시즌 1', '시즌 2'];
  int seasonForStatics = 0;
  int selectedStudent = 0;
  List<double> forCorrectRate = [];

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

    getSummary();
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
        StudyInfoModel rates = summary.rates;
        forCorrectRate.clear();

        for (int i = 0; i < rates.releasedLevel!; i++) {
          forCorrectRate
              .add(rates.correctRateNormal![i] + rates.correctRateAI![i]);
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
                        left: 64.r,
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
                                  setState(() {
                                    selectedStudent = index;
                                    getSummary();
                                  });
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
                        left: 220.r,
                        child: Container(
                          width: 346.r,
                          height: 250.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8).r,
                          ),
                          child: Stack(
                            children: [
                              // error rate
                              Positioned(
                                top: 43.r,
                                left: 29.5.r,
                                child: PieChartWidget(
                                  width: 110.r,
                                  height: 110.r,
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
                                      '지금까지 어순과 격에서의\n오답율이 가장 적어요.',
                                      style: textStyle14.copyWith(),
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
                                      '어순과 격',
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
                                      '부정문',
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
                                            initialPage: 1,
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
                      // select season for statics
                      Positioned(
                        top: 0,
                        right: 64.r,
                        child: Container(
                          width: 166.r,
                          height: 46.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8).r,
                          ),
                          child: SizedBox(
                            width: 166.r,
                            height: 36.r,
                            child: CustomDropdown(
                              closedHeaderPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10)
                                  .r,
                              expandedHeaderPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10)
                                  .r,
                              listItemPadding: EdgeInsets.symmetric(
                                  horizontal: 15.r, vertical: 10.r),
                              decoration: CustomDropdownDecoration(
                                closedBorderRadius: BorderRadius.circular(8).r,
                                expandedBorderRadius:
                                    BorderRadius.circular(8).r,
                                headerStyle:
                                    textStyle14.copyWith(fontSize: 13.sp),
                                listItemStyle:
                                    textStyle14.copyWith(fontSize: 13.sp),
                              ),
                              initialItem: seasonList[seasonForStatics],
                              items: seasonList,
                              onChanged: (value) {
                                seasonForStatics = seasonList.indexOf(value!);
                                setState(() {
                                  getSummary();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      // study time
                      Positioned(
                        top: 54.r,
                        right: 64.r,
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
                                  width: 56.r,
                                  child: Text(
                                    '${summary.totalStudyTime}시간',
                                    textAlign: TextAlign.center,
                                    style: textStyle14.copyWith(
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 7.r,
                                left: 62.r,
                                child: SizedBox(
                                  width: 56.r,
                                  child: Text(
                                    '총 학습 시간',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
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
                        right: 64.r,
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
                                      '단어 순서 오류',
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
                                      '어순과 격',
                                      style: textStyle11,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '부정문',
                                      style: textStyle11,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '의문문',
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
                                      '57%',
                                      style: textStyle11,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '83%',
                                      style: textStyle11,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '42%',
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
