import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/status.dart';
import 'package:block_english/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String info = '/';
const String season = '/season';
const String setting = '/setting';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});
  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  MaterialPageRoute _onGenerateRoute(RouteSettings setting) {
    if (setting.name == info) {
      return MaterialPageRoute<dynamic>(
          builder: (context) => Info(
                onLogoutPressed: onLogoutPressed,
              ),
          settings: setting);
    }
    // else if (setting.name == season) {
    //   return MaterialPageRoute<dynamic>(
    //       builder: (context) => B(), settings: setting);
    // } else if (setting.name == setting) {
    //   return MaterialPageRoute<dynamic>(
    //       builder: (context) => C(), settings: setting);
    // }
    else {
      throw Exception('Unknown route: ${setting.name}');
    }
  }

  onLogoutPressed() async {
    final storage = ref.watch(secureStorageProvider);
    final result = await ref
        .watch(authServiceProvider)
        .postAuthLogout(await storage.readRefreshToken() ?? "");

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('애플리케이션을 재시작해 주세요'),
            ),
          );
        }
      },
      (response) {
        if (response.statusCode == 200) {
          storage.removeTokens();

          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login_screen',
            (Route<dynamic> route) => false,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('다시해'),
              ),
            );
          }
        }
      },
    );
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
                  top: 189,
                ).r,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: Size(302.r, 44.r),
                        backgroundColor: const Color(0xFF93E54C),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ).r,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8).r,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        '내 정보',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.r),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: Size(302.r, 44.r),
                        backgroundColor: const Color(0xFFBEEF94),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ).r,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8).r,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        '블록 잉글리시 보유 시즌 추가',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.r),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: Size(302.r, 44.r),
                        backgroundColor: const Color(0xFFBEEF94),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8).r,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        '환경 설정',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                  top: 32,
                  left: 64,
                ).r,
                child: SizedBox(
                  width: 302.r,
                  height: 156.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          SvgPicture.asset(
                            'assets/images/profile_photo.svg',
                            width: 72.r,
                            height: 72.r,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  'assets/buttons/rounded_edit_button.svg',
                                  width: 24.r,
                                  height: 24.r,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 3),
                      Text(
                        ref.watch(statusProvider).name,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Text(
                        ref.watch(statusProvider).groupName ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(flex: 6),
                    ],
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
                  child: Navigator(
                    key: _navigatorKey,
                    initialRoute: info,
                    onGenerateRoute: _onGenerateRoute,
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
  final VoidCallback onLogoutPressed;
  const Info({super.key, required this.onLogoutPressed});
  @override
  ConsumerState<Info> createState() => _InfoState();
}

class _InfoState extends ConsumerState<Info> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '계정 정보',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(flex: 8),
        Container(
          width: 302.r,
          height: 76.r,
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
                    minimumSize: Size(91.r, 36.r),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ).r,
                  ),
                  onPressed: () {},
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
        const Spacer(flex: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '내 모니터링 관리자',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('추가하기');
              },
              child: Text(
                '추가하기',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Spacer(flex: 8),
        Container(
          height: 110.r,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ).r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8).r,
            color: const Color(0xFFE9FADB),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 41.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20).r,
                      color: const Color(0xFF93E54C),
                    ),
                    child: Text(
                      '그룹',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 21.r),
                  Text(
                    ref.watch(statusProvider).groupName ?? '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 41.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20).r,
                      color: const Color(0xFF93E54C),
                    ),
                    child: Text(
                      '개인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 21.r),
                  // TODO: Change this to the actual name of parent
                  Text(
                    '김관리 관리자',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(flex: 7),
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
                onTap: widget.onLogoutPressed,
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16.r),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '계정 탈퇴',
                  style:
                      TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
