import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String info = '/';
const String season = '/season';
const String setting = '/setting';

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

class SuperProfileScreen extends ConsumerStatefulWidget {
  const SuperProfileScreen({super.key});
  @override
  ConsumerState<SuperProfileScreen> createState() => _SuperProfileScreenState();
}

class _SuperProfileScreenState extends ConsumerState<SuperProfileScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  int currentPage = 1;
  Color? unselectedFontColor = const Color(0xFF76B73D);
  Color? selectedFontColor = const Color(0xFF58892E);
  Color? unselectedBackgroundColor = Colors.white;
  Color? selectedBackgroundColor = const Color(0xFFA9EA70);
  Color selectedBorderColor = const Color(0xFF8AD24C);

  onMenuPressed(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState!.pushReplacementNamed(route);
    });
  }

  onChangePasswordPressed() {
    Navigator.of(context).pushNamed('/user_change_password_screen');
  }

  onAccountPressed() {
    Navigator.of(context).pushNamed('/user_manage_account_screen');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F7D4),
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
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: SvgPicture.asset(
                    'assets/buttons/round_back_button.svg',
                    width: 48.r,
                    height: 48.r,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 64,
                  top: 229,
                ).r,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () {
                        if (currentPage != 1) {
                          onMenuPressed(info);
                          setState(() {
                            currentPage = 1;
                          });
                        }
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: Size(302.w, 44.r),
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
                        '내 정보',
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
                        if (currentPage != 3) {
                          onMenuPressed(setting);
                          setState(() {
                            currentPage = 3;
                          });
                        }
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: Size(302.r, 44.r),
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
                        '환경 설정',
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
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 180,
                  left: 64,
                ).r,
                child: Text(
                  ref.watch(statusProvider).name,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 406.r,
                height: 1.sh,
                color: Colors.white,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  right: 64,
                ).r,
                child: SizedBox(
                  width: 302.r,
                  height: 319.r,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Navigator(
                      key: _navigatorKey,
                      initialRoute: info,
                      onGenerateRoute: (settings) {
                        return CustomRoute(
                          //fullscreenDialog: true,
                          builder: (context) {
                            switch (settings.name) {
                              case info:
                                return Info(
                                  onChangePasswordPressed:
                                      onChangePasswordPressed,
                                  onAccountPressed: onAccountPressed,
                                );
                              case setting:
                                return const Settings();
                              default:
                                return Info(
                                  onChangePasswordPressed:
                                      onChangePasswordPressed,
                                  onAccountPressed: onAccountPressed,
                                );
                            }
                          },
                        );
                      },
                    ),
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

class Info extends ConsumerStatefulWidget {
  final VoidCallback onChangePasswordPressed;
  final VoidCallback onAccountPressed;

  const Info({
    super.key,
    required this.onChangePasswordPressed,
    required this.onAccountPressed,
  });
  @override
  ConsumerState<Info> createState() => _InfoState();
}

class _InfoState extends ConsumerState<Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '계정 정보',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.r),
          Container(
            width: 318.r,
            height: 68.r,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8).r,
              color: const Color(0xFFE9FADB),
            ),
            child: SizedBox(
              width: 270.r,
              height: 44.r,
              child: Row(
                children: [
                  Text(
                    '아이디',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 16.r),
                  Text(
                    ref.watch(statusProvider).username,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF93E54C),
                      minimumSize: Size(91.r, 26.r),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ).r,
                    ),
                    onPressed: widget.onChangePasswordPressed,
                    child: Text(
                      '비밀번호 변경',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.r),
          Container(
            alignment: Alignment.center,
            height: 48.r,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8).r,
              color: const Color(0xFFE9FADB),
            ),
            child: Row(
              children: [
                Text(
                  '계정 관리',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onAccountPressed,
                  child: Row(
                    children: [
                      Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16.r),
                      Text(
                        '계정 탈퇴',
                        style: TextStyle(
                            fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '환경설정',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.r),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: null,
            icon: SvgPicture.asset(
              'assets/buttons/settings_notification_button.svg',
              width: 302.r,
              height: 48.r,
            ),
          ),
          SizedBox(height: 8.r),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: null,
            icon: SvgPicture.asset(
              'assets/buttons/settings_app_version_button.svg',
              width: 302.r,
              height: 48.r,
            ),
          ),
          SizedBox(height: 8.r),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: null,
            icon: SvgPicture.asset(
              'assets/buttons/settings_copyright_button.svg',
              width: 302.r,
              height: 48.r,
            ),
          ),
        ],
      ),
    );
  }
}
