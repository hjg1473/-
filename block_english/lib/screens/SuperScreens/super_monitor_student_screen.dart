import 'package:block_english/models/MonitoringModel/study_info_model.dart';
import 'package:block_english/models/model.dart';
import 'package:block_english/services/student_service.dart';
import 'package:block_english/utils/color.dart';
import 'package:block_english/utils/text_style.dart';
import 'package:block_english/widgets/ChartWidget/bar_chart_widget.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/widgets/ChartWidget/pie_chart_widget.dart';
import 'package:block_english/widgets/cool_drop_down_button.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:cool_dropdown/controllers/dropdown_controller.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
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

class MonitorStudentScreen extends ConsumerStatefulWidget {
  const MonitorStudentScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    this.groupName = '',
    required this.initialPage,
  });

  final String studentName;
  final int studentId;
  final String groupName;
  final int initialPage;

  @override
  ConsumerState<MonitorStudentScreen> createState() =>
      _MonitorStudentScreenState();
}

class _MonitorStudentScreenState extends ConsumerState<MonitorStudentScreen> {
  List<String> seasonList = ['시즌 1', '시즌 2'];
  List<CoolDropdownItem<String>> seasonDropdownItems = [];
  final seasonDropdownController = DropdownController<String>();
  int seasonForStatics = 0;
  int currentPage = 1;
  Color? unselectedFontColor = const Color(0xFF8A8A8A);
  Color? selectedFontColor = Colors.white;
  Color? unselectedBackgroundColor = const Color(0xFFE4E4E4);
  Color? selectedBackgroundColor = primaryPurple[400];
  Color selectedBorderColor = const Color(0xFFAD3DF1);

  void updateSeason(int season) {
    setState(() {
      seasonForStatics = season;
    });
  }

  Future<void> deleteStudent() async {
    final response = await ref
        .watch(superServiceProvider)
        .putRemoveStudentInGroup(widget.studentId);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('삭제되었습니다.'),
        ),
      );
      Navigator.of(context).pop(true);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPage = widget.initialPage;
    seasonDropdownItems = seasonList
        .map((e) => CoolDropdownItem<String>(value: e, label: e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Stack(
          children: [
            Positioned(
              left: 139.r,
              top: 40.r,
              child: CoolDropDownButton(
                controller: seasonDropdownController,
                dropdownList: seasonDropdownItems,
                defaultItem: seasonDropdownItems[seasonForStatics],
                onChange: (value) {
                  updateSeason(seasonList.indexOf(value));
                },
                width: 100.45.r,
                height: 36.r,
                backgroundColor: Colors.white,
                primaryColor: primaryPurple[500]!,
                textStyle: textStyle14,
              ),
            ),
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
                      SizedBox(height: 2.r),
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
                          setState(() {
                            currentPage = 2;
                          });
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
                          widget.studentId == -1 ? '기타 관리' : '학습자 관리',
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
              child: SizedBox(
                width: 539.r,
                height: 1.sh,
                child: currentPage == 1
                    ? LearningAnalysis(
                        userId: widget.studentId,
                        userName: widget.studentName,
                        season: seasonForStatics + 1,
                      )
                    : currentPage == 2
                        ? Incorrect(
                            userId: widget.studentId,
                            userName: widget.studentName,
                            season: seasonForStatics + 1,
                          )
                        : ManageStudent(
                            userId: widget.studentId,
                            onDeletePressed: () {
                              _showDeleteDialog(context);
                            },
                            season: seasonForStatics + 1,
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
  const LearningAnalysis({
    super.key,
    required this.userId,
    required this.userName,
    required this.season,
  });
  final int userId;
  final String userName;
  final int season;

  @override
  ConsumerState<LearningAnalysis> createState() => _LearningAnalysisState();
}

class _LearningAnalysisState extends ConsumerState<LearningAnalysis> {
  bool isLoading = true;
  List<StudyInfoModel> studyInfo = [];
  List<double> correctRate = [];
  int bestLevel = -1;
  int basicBest = -1;
  int expertBest = -1;

  waitForData() async {
    debugPrint('waiting for data');
    final response = widget.userId == -1
        ? await ref
            .watch(studentServiceProvider)
            .getMonitoringCorrectRate(widget.season)
        : await ref
            .watch(superServiceProvider)
            .postUserMonitoringStudyRate(widget.userId, widget.season);

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
      correctRate.clear();
      for (int i = 0; i < last.releasedLevel! + 1; i++) {
        correctRate.add(last.correctRateNormal![i] + last.correctRateAI![i]);
        if (bestLevel == -1 || correctRate[i] > correctRate[bestLevel]) {
          bestLevel = i;
        }
      }
      debugPrint(correctRate.toString());

      for (int i = 0; i < 3; i++) {
        double basicBestCorrectRate = 0;
        double expertBestCorrectRate = 0;
        if (last.correctRateNormal![i] > basicBestCorrectRate) {
          basicBest = i;
          basicBestCorrectRate = last.correctRateNormal![i];
        }
        if (last.correctRateAI![i] > expertBestCorrectRate) {
          expertBest = i;
          basicBestCorrectRate = last.correctRateAI![i];
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    waitForData();
  }

  @override
  void didUpdateWidget(covariant LearningAnalysis oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.season != widget.season) {
      isLoading = true;
      waitForData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECECEC),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 64, 24).r,
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
                        width: 297.r,
                        height: 142.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8).r,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 31.r,
                              left: 31.r,
                              child: PieChartWidget(
                                width: 89.r,
                                height: 88.r,
                                data: correctRate,
                              ),
                            ),
                            Positioned(
                              top: 29.r,
                              left: 96.r,
                              child: SvgPicture.asset(
                                'assets/images/angled_connecting_line_small.svg',
                                height: 20.r,
                              ),
                            ),
                            Positioned(
                              top: 18.r,
                              left: 125.r,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    bestLevel == -1
                                        ? '데이터 없음'
                                        : '${correctRate[bestLevel].toInt()}%',
                                    style: textStyle14,
                                  ),
                                  SizedBox(width: 8.r),
                                  Container(
                                    width: 79.r,
                                    height: 26.r,
                                    decoration: BoxDecoration(
                                      color: primaryPurple[500],
                                      borderRadius: BorderRadius.circular(20).r,
                                    ),
                                    child: Center(
                                      child: Text(
                                        bestLevel == -1
                                            ? '데이터 없음'
                                            : levelList[bestLevel],
                                        style: textStyle14.copyWith(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 23.r,
                              right: 20.r,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '이 문제를 잘했어요!',
                                    style: textStyle16,
                                  ),
                                  SizedBox(height: 6.r),
                                  Text(
                                    bestLevel == -1
                                        ? '기록 없음'
                                        : '지금까지 ${levelList[bestLevel]}에서의\n정답률이 가장 높아요.',
                                    style: textStyle11,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 138.r,
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
                                  vertical: 3,
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
                                basicBest == -1
                                    ? '데이터 없음'
                                    : levelList[basicBest],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(flex: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 3,
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
                                expertBest == -1
                                    ? '데이터 없음'
                                    : levelList[expertBest],
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
                                '단원별 오답률',
                                style: textStyle14,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12).r,
                                child: SizedBox(
                                  width: 234.r,
                                  height: 112.r,
                                  child: BarChartWidget(data: correctRate),
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
    required this.season,
  });
  final int userId;
  final String userName;
  final int season;

  @override
  ConsumerState<Incorrect> createState() => _IncorrectState();
}

class _IncorrectState extends ConsumerState<Incorrect> {
  bool isLoading = true;
  IncorrectModel? incorrectData;
  List<MapEntry<String, double>> sortedData = [];
  List<double> chartData = [0, 0, 0, 0, 0];

  waitForData() async {
    final response = widget.userId == -1
        ? await ref
            .watch(studentServiceProvider)
            .getMonitoringIncorrect(widget.season)
        : await ref
            .watch(superServiceProvider)
            .postUserMonitoringIncorrect(widget.userId, widget.season);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      //TODO: check mapping weakParts
      incorrectData = data;
      if (incorrectData == null) {
        return;
      }
      sortedData = incorrectData!.weakParts.getTopNRates(5);
      for (int i = 0; i < 5; i++) {
        chartData[i] = sortedData[i].value;
      }
    });
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    waitForData();
  }

  @override
  void didUpdateWidget(covariant Incorrect oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.season != widget.season) {
      isLoading = true;
      waitForData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECECEC),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 64, 24).r,
        child: Container(
          width: 445.r,
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
                        child: PieChartWidget(
                          width: 171,
                          height: 171,
                          data: chartData,
                        ),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 1).r,
                                child: Container(
                                  width: 20.r,
                                  height: 20.r,
                                  decoration: BoxDecoration(
                                    color: primaryPink[500],
                                    borderRadius: BorderRadius.circular(20).r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString(sortedData[0].key)} 오답 (${(sortedData[0].value * 100).toInt()}%)',
                                      style: textStyle16.copyWith(
                                          fontWeight: FontWeight.w800)),
                                  Text(
                                    wrongDetailToString(sortedData[0].key),
                                    style: textStyle11.copyWith(
                                      color: const Color(0xFF818181),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1).r,
                                child: Container(
                                  width: 20.r,
                                  height: 20.r,
                                  decoration: BoxDecoration(
                                    color: primaryYellow[500],
                                    borderRadius: BorderRadius.circular(20).r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString(sortedData[1].key)} 오답 (${(sortedData[1].value * 100).toInt()}%)',
                                      style: textStyle16.copyWith(
                                          fontWeight: FontWeight.w800)),
                                  Text(
                                    wrongDetailToString(sortedData[1].key),
                                    style: textStyle11.copyWith(
                                      color: const Color(0xFF818181),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1).r,
                                child: Container(
                                  width: 20.r,
                                  height: 20.r,
                                  decoration: BoxDecoration(
                                    color: primaryGreen[500],
                                    borderRadius: BorderRadius.circular(20).r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString(sortedData[2].key)} 오답 (${(sortedData[2].value * 100).toInt()}%)',
                                      style: textStyle16.copyWith(
                                          fontWeight: FontWeight.w800)),
                                  Text(
                                    wrongDetailToString(sortedData[2].key),
                                    style: textStyle11.copyWith(
                                      color: const Color(0xFF818181),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1).r,
                                child: Container(
                                  width: 20.r,
                                  height: 20.r,
                                  decoration: BoxDecoration(
                                    color: primaryBlue[500],
                                    borderRadius: BorderRadius.circular(20).r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString(sortedData[3].key)} 오답 (${(sortedData[3].value * 100).toInt()}%)',
                                      style: textStyle16.copyWith(
                                          fontWeight: FontWeight.w800)),
                                  Text(
                                    wrongDetailToString(sortedData[3].key),
                                    style: textStyle11.copyWith(
                                      color: const Color(0xFF818181),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20.r),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1).r,
                                child: Container(
                                  width: 20.r,
                                  height: 20.r,
                                  decoration: BoxDecoration(
                                    color: primaryPurple[500],
                                    borderRadius: BorderRadius.circular(20).r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 13.r),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${wrongToString(sortedData[4].key)} 오답 (${(sortedData[4].value * 100).toInt()}%)',
                                      style: textStyle16.copyWith(
                                          fontWeight: FontWeight.w800)),
                                  Text(
                                    wrongDetailToString(sortedData[4].key),
                                    style: textStyle11.copyWith(
                                      color: const Color(0xFF818181),
                                    ),
                                  ),
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
    required this.season,
  });
  final int userId;
  final VoidCallback onDeletePressed;
  final int season;

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
    waitForData();
  }

  waitForData() async {
    isLoading = true;
    final response = widget.userId == -1
        ? await ref.watch(studentServiceProvider).getMonitoringEtc()
        : await ref
            .watch(superServiceProvider)
            .postUserMonitoringEtc(widget.userId, widget.season);

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
                      height: 65.r,
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                    padding:
                        EdgeInsets.only(top: widget.userId == -1 ? 140 : 123).r,
                    child: Lottie.asset(
                      width: 334.r,
                      //height: 166.r,
                      'assets/lottie/motion_13.json',
                    ),
                  ),
                ),
                widget.userId == -1
                    ? const SizedBox()
                    : Align(
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
