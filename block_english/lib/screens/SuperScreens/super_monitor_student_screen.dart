import 'package:block_english/models/MonitoringModel/study_info_model.dart';
import 'package:block_english/models/MonitoringModel/weak_part_model.dart';
import 'package:block_english/utils/color.dart';
import 'package:block_english/widgets/ChartWidget/bar_chart_widget.dart';
import 'package:block_english/widgets/ChartWidget/line_chart_widget.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/ChartWidget/pie_chart_widget.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

const String learning = '/';
const String incorrect = '/incorrect';
const String manage = '/manage';

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

class MonitorStudentScreen extends StatefulWidget {
  const MonitorStudentScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    this.groupName = '',
  });

  final String studentName;
  final int studentId;
  final String groupName;

  @override
  State<MonitorStudentScreen> createState() => _MonitorStudentScreenState();
}

class _MonitorStudentScreenState extends State<MonitorStudentScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  int currentPage = 1;
  Color? unselectedFontColor = const Color(0xFF8A8A8A);
  Color? selectedFontColor = Colors.white;
  Color? unselectedBackgroundColor = const Color(0xFFE4E4E4);
  Color? selectedBackgroundColor = primaryPurple[400];
  Color selectedBorderColor = const Color(0xFFAD3DF1);

  onMenuPressed(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState!.pushReplacementNamed(route);
    });
  }

  Future<dynamic> _showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.02).r,
        ),
        titlePadding: const EdgeInsets.only(
          top: 28,
          bottom: 8,
        ).r,
        title: Center(
          child: Text(
            '학습자 삭제',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
        ).r,
        content: Text(
          '학습자를 삭제하면\n더이상 모니터링이 불가합니다\n\n정말 삭제하시겠습니까?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA7A7A7),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          20,
          32,
          20,
          20,
        ).r,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6).r,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 53,
                ).r,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.02).r,
                ),
                backgroundColor: const Color(0xFF919191),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          //TODO: Add delete function
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 11,
                horizontal: 53,
              ).r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.02).r,
              ),
              backgroundColor: primaryPink[500],
            ),
            child: Text(
              '삭제',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 64,
                ).r,
                child: SizedBox(
                  height: 319.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: SvgPicture.asset(
                          'assets/buttons/round_back_button.svg',
                          width: 48.r,
                          height: 48.r,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Text(
                        widget.studentName,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 7.r),
                      Text(
                        widget.groupName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(flex: 1),
                      FilledButton(
                        onPressed: () {
                          if (currentPage != 1) {
                            onMenuPressed(learning);
                            setState(() {
                              currentPage = 1;
                            });
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: Size(185.r, 44.r),
                          backgroundColor: currentPage == 1
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ).r,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8).r,
                            side: currentPage == 1
                                ? BorderSide(
                                    color: selectedBorderColor,
                                  )
                                : BorderSide.none,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          '학습 분석',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: currentPage == 1
                                ? selectedFontColor
                                : unselectedFontColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.r),
                      FilledButton(
                        onPressed: () {
                          if (currentPage != 2) {
                            onMenuPressed(incorrect);
                            setState(() {
                              currentPage = 2;
                            });
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: Size(185.r, 44.r),
                          backgroundColor: currentPage == 2
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ).r,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8).r,
                            side: currentPage == 2
                                ? BorderSide(
                                    color: selectedBorderColor,
                                  )
                                : BorderSide.none,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          '오답 분석',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: currentPage == 2
                                ? selectedFontColor
                                : unselectedFontColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.r),
                      FilledButton(
                        onPressed: () {
                          if (currentPage != 3) {
                            onMenuPressed(manage);
                            setState(() {
                              currentPage = 3;
                            });
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: Size(185.r, 44.r),
                          backgroundColor: currentPage == 3
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8).r,
                            side: currentPage == 3
                                ? BorderSide(
                                    color: selectedBorderColor,
                                  )
                                : BorderSide.none,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          '학습자 관리',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: currentPage == 3
                                ? selectedFontColor
                                : unselectedFontColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 539.r,
                height: 1.sh,
                color: const Color(0xFFECECEC),
                child: Navigator(
                  key: _navigatorKey,
                  initialRoute: learning,
                  onGenerateRoute: (settings) {
                    return CustomRoute(
                      builder: (context) {
                        switch (settings.name) {
                          case learning:
                            return LearningAnalysis(
                              userId: widget.studentId,
                              userName: widget.studentName,
                            );
                          case incorrect:
                            return Incorrect(
                                userId: widget.studentId,
                                userName: widget.studentName);
                          case manage:
                            return ManageStudent(
                              userId: widget.studentId,
                              onDeletePressed: () {
                                _showDeleteDialog(context);
                              },
                            );
                          default:
                            return LearningAnalysis(
                              userId: widget.studentId,
                              userName: widget.studentName,
                            );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearningAnalysis extends ConsumerStatefulWidget {
  const LearningAnalysis(
      {super.key, required this.userId, required this.userName});
  final int userId;
  final String userName;

  @override
  ConsumerState<LearningAnalysis> createState() => _LearningAnalysisState();
}

class _LearningAnalysisState extends ConsumerState<LearningAnalysis> {
  bool isLoading = true;
  List<StudyInfoModel> studyInfo = [];
  List<double> forCorrectRate = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //waitForData();
    isLoading = false;
  }

  waitForData() async {
    final response = await ref
        .watch(superServiceProvider)
        .postUserMonitoringStudyRate(widget.userId, 1);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      studyInfo = data;
      if (studyInfo.isEmpty) {
        return;
      }
      StudyInfoModel last = studyInfo.last;
      for (int i = 0; i < last.releasedLevel!; i++) {
        forCorrectRate.add(last.correctRateNormal![i] + last.correctRateAI![i]);
      }
    });
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECECEC),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 44, 24).r,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.grey,
                ),
              )
            : Container(
                width: 471.r,
                height: 327.r,
                color: const Color(0xFFECECEC),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 307.r,
                        height: 142.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8).r,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 148.r,
                        height: 142.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8).r,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 17).r,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ).r,
                                decoration: BoxDecoration(
                                  color: primaryPurple[500],
                                  borderRadius: BorderRadius.circular(20).r,
                                ),
                                child: Text(
                                  'Basic BEST',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(flex: 2),
                              Text(
                                // Basic best level
                                levelList[0],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(flex: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ).r,
                                decoration: BoxDecoration(
                                  color: primaryPurple[500],
                                  borderRadius: BorderRadius.circular(20).r,
                                ),
                                child: Text(
                                  'Expert BEST',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(flex: 2),
                              Text(
                                // Basic best level
                                levelList[1],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: 274.r,
                        height: 170.r,
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          16,
                          0,
                          0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8).r,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                '단원별 정답률',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12).r,
                                child: SizedBox(
                                  width: 234.r,
                                  height: 112.r,
                                  child: BarChartWidget(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //TODO: display svg image
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        'assets/images/monitor_character_1.png',
                        width: 131.r,
                        height: 147.r,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class Incorrect extends ConsumerStatefulWidget {
  const Incorrect({
    super.key,
    required this.userId,
    required this.userName,
  });
  final int userId;
  final String userName;

  @override
  ConsumerState<Incorrect> createState() => _IncorrectState();
}

class _IncorrectState extends ConsumerState<Incorrect> {
  bool isLoading = true;
  List<WeakPartModel> weakParts = [];
  String weakest = '';
  String recentProblem = '';
  String recentAnswer = '';
  String recentDetail = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //waitForData();
    isLoading = false;
  }

  waitForData() async {
    final response = await ref
        .watch(superServiceProvider)
        .postUserMonitoringIncorrect(widget.userId, 1);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      //TODO: check mapping weakParts
      weakParts = data.weakParts;
      weakest = data.weakest;
      recentProblem = data.recentProblem ?? 'I love block english.';
      recentAnswer = data.recentAnswer ?? 'I block english love.';
      recentDetail = data.recentDetail;
    });
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECECEC),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 44, 24).r,
        child: Container(
          width: 465.r,
          height: 327.r,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8).r,
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                )
              : Stack(
                  children: [
                    Positioned(
                      top: 56.r,
                      left: 70.r,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryPurple[500],
                          borderRadius: BorderRadius.circular(20).r,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.r,
                          vertical: 4.r,
                        ),
                        child: Text(
                          '오답 분석',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100.r,
                      left: 28.r,
                      child: SizedBox(
                        width: 171.r,
                        child: const PieChartWidget(),
                      ),
                    ),
                    Positioned(
                      top: 31.r,
                      left: 230.r,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20.r,
                                height: 20.r,
                                decoration: BoxDecoration(
                                  color: primaryPink[500],
                                  borderRadius: BorderRadius.circular(20).r,
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString('wrong_order')} 오답 (20%)',
                                      style: TextStyle(
                                        fontSize: 16.r,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  Text('단어 순서를 헷갈렸어요.',
                                      style: TextStyle(
                                        fontSize: 11.r,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF818181),
                                      )),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20.r,
                                height: 20.r,
                                decoration: BoxDecoration(
                                  color: primaryYellow[500],
                                  borderRadius: BorderRadius.circular(20).r,
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString('wrong_punctuation')} 오답 (20%)',
                                      style: TextStyle(
                                        fontSize: 16.r,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  Text('문장 부호를 잘못 넣었어요.',
                                      style: TextStyle(
                                        fontSize: 11.r,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF818181),
                                      )),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20.r,
                                height: 20.r,
                                decoration: BoxDecoration(
                                  color: primaryGreen[500],
                                  borderRadius: BorderRadius.circular(20).r,
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString('wrong_block')} 오답 (20%)',
                                      style: TextStyle(
                                        fontSize: 16.r,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  Text('단어를 알맞게 변형하지 못했어요.',
                                      style: TextStyle(
                                        fontSize: 11.r,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF818181),
                                      )),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20.r,
                                height: 20.r,
                                decoration: BoxDecoration(
                                  color: primaryBlue[500],
                                  borderRadius: BorderRadius.circular(20).r,
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString('wrong_word')} 오답 (20%)',
                                      style: TextStyle(
                                        fontSize: 16.r,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  Text('올바른 단어를 사용하지 않았어요.',
                                      style: TextStyle(
                                        fontSize: 11.r,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF818181),
                                      )),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20.r,
                                height: 20.r,
                                decoration: BoxDecoration(
                                  color: primaryPurple[500],
                                  borderRadius: BorderRadius.circular(20).r,
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('기타 (20%)',
                                      style: TextStyle(
                                        fontSize: 16.r,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  // Text('올바른 단어를 사용하지 않았어요.',
                                  //     style: TextStyle(
                                  //       fontSize: 11.r,
                                  //       fontWeight: FontWeight.bold,
                                  //       color: const Color(0xFF818181),
                                  //     )),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ManageStudent extends ConsumerStatefulWidget {
  const ManageStudent({
    super.key,
    required this.userId,
    required this.onDeletePressed,
  });
  final int userId;
  final VoidCallback onDeletePressed;

  @override
  ConsumerState<ManageStudent> createState() => _ManageStudentState();
}

class _ManageStudentState extends ConsumerState<ManageStudent> {
  bool isLoading = true;
  int totalStudyTime = 0;
  int streamStudyDay = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //waitForData();
    isLoading = false;
  }

  waitForData() async {
    final response = await ref
        .watch(superServiceProvider)
        .postUserMonitoringEtc(widget.userId, 1);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      totalStudyTime = data.totalStudyTime;
      streamStudyDay = data.streamStudyDay;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 425.r,
      height: 327.r,
      color: const Color(0xFFECECEC),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 46).r,
                    child: Container(
                      width: 256.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      padding: const EdgeInsets.all(12).r,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/monitor_day_icon.svg',
                            height: 32.r,
                          ),
                          SizedBox(width: 8.r),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '$streamStudyDay일째',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '연속 학습 시간',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB2B2B2),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20.r),
                          SvgPicture.asset(
                            'assets/images/monitor_time_icon.svg',
                            height: 32.r,
                          ),
                          SizedBox(width: 8.r),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '$totalStudyTime시간',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '총 학습 시간',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB2B2B2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 123).r,
                    child: Lottie.asset(
                      width: 334.r,
                      //height: 166.r,
                      'assets/lottie/motion_13.json',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SquareButton(
                    text: '학습자 삭제',
                    onPressed: widget.onDeletePressed,
                  ),
                ),
              ],
            ),
    );
  }
}
