import 'package:block_english/models/StudentModel/student_weak_part_model.dart';
import 'package:block_english/services/super_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String learning = '/';
const String wrongAnswers = '/wrong_answers';
const String manage = '/manage';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required super.builder});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    //return FadeTransition(opacity: animation, child: child);
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
              //.chain(CurveTween(curve: Curves.linear))
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
  Color? unselectedFontColor = Colors.black;
  Color? selectedFontColor = const Color(0xFF58892E);
  Color? unselectedBackgroundColor = const Color(0xFFD9D9D9);
  Color? selectedBackgroundColor = const Color(0xFFA9EA70);
  Color selectedBorderColor = const Color(0xFF8AD24C);

  onMenuPressed(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState!.pushReplacementNamed(route);
    });
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
                ).h,
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
                          minimumSize: Size(176.r, 48.r),
                          backgroundColor: currentPage == 1
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
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
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: currentPage == 1
                                ? selectedFontColor
                                : unselectedFontColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.r),
                      FilledButton(
                        onPressed: () {
                          if (currentPage != 2) {
                            onMenuPressed(wrongAnswers);
                            setState(() {
                              currentPage = 2;
                            });
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: Size(176.r, 48.r),
                          backgroundColor: currentPage == 2
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
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
                            fontSize: 16.sp,
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
                          minimumSize: Size(176.r, 48.r),
                          backgroundColor: currentPage == 3
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
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
                            fontSize: 16.sp,
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
                width: 553.r,
                height: 1.sh,
                color: const Color(0xFFECECEC),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 24,
                ).r,
                child: SizedBox(
                  width: 465.r,
                  height: 327.r,
                  child: Navigator(
                    key: _navigatorKey,
                    initialRoute: learning,
                    onGenerateRoute: (settings) {
                      return CustomRoute(
                        builder: (context) {
                          switch (settings.name) {
                            case learning:
                              return LearningAnalysis(userId: widget.studentId);
                            case wrongAnswers:
                              return WrongAnswers(userId: widget.studentId);
                            case manage:
                              return ManageStudent(userId: widget.studentId);
                            default:
                              return LearningAnalysis(userId: widget.studentId);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearningAnalysis extends StatelessWidget {
  const LearningAnalysis({super.key, required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFECECEC),
      body: Stack(
        children: [
          Center(
            child: Text('Learning Analysis'),
          ),
        ],
      ),
    );
  }
}

class WrongAnswers extends ConsumerStatefulWidget {
  const WrongAnswers({super.key, required this.userId});
  final int userId;

  @override
  ConsumerState<WrongAnswers> createState() => _WrongAnswersState();
}

class _WrongAnswersState extends ConsumerState<WrongAnswers> {
  bool isLoading = true;
  List<WeakPartModel> weakParts = [];
  String weakest = '';
  String recentProblem = '';
  String recentAnswer = '';
  String recentDetail = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    waitForData();
  }

  waitForData() async {
    final response = await ref
        .watch(superServiceProvider)
        .postUserMonitoringIncorrect(widget.userId);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      //TODO: check mapping weakParts
      weakParts = data.weakParts
          .map((weakPart) => WeakPartModel.fromJson(weakPart))
          .toList();
      weakest = data.weakest;
      recentProblem = data.recentProblem ?? '';
      recentAnswer = data.recentAnswer ?? '';
      recentDetail = data.recentDetail;

      debugPrint('userId: ${widget.userId} weakest: $weakest');
    });
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : Stack(
              children: [
                Container(
                  width: 465.r,
                  height: 152.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8).r,
                  ),
                  child: const Row(
                    children: [
                      Text('오류 분석'),
                      Column(
                        children: [],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class ManageStudent extends StatelessWidget {
  const ManageStudent({super.key, required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFECECEC),
      body: Stack(
        children: [
          Center(
            child: Text('Manage Student'),
          ),
        ],
      ),
    );
  }
}
