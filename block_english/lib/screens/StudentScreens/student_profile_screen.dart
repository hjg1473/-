import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/status.dart';
import 'package:block_english/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});
  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
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
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login_screen',
              (Route<dynamic> route) => false,
            );
          }
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
              alignment: const Alignment(0.5, 0),
              child: FilledButton(
                onPressed: onLogoutPressed,
                child: const Text("로그아웃"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
