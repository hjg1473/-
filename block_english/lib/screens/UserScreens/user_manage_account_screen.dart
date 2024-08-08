import 'package:block_english/services/auth_service.dart';
import 'package:block_english/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserManageAccountScreen extends ConsumerStatefulWidget {
  const UserManageAccountScreen({super.key});

  @override
  ConsumerState<UserManageAccountScreen> createState() =>
      _UserManageAccountScreenState();
}

class _UserManageAccountScreenState
    extends ConsumerState<UserManageAccountScreen> {
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

  Future<dynamic> _showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.02).r,
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          8,
        ).r,
        title: Center(
          child: Text(
            '로그아웃',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20).r,
        content: Text(
          '로그아웃 하시겠습니까?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA7A7A7),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 32, 20, 20).r,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
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
          FilledButton(
            onPressed: onLogoutPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 53,
              ).r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.02).r,
              ),
              backgroundColor: const Color(0xFF93E54C),
            ),
            child: Text(
              '확인',
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

  Future<dynamic> _showQuitDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.02).r,
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          12,
        ).r,
        title: Center(
          child: Text(
            '계정 탈퇴',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20).r,
        content: Text(
          '탈퇴 시 계정 정보 및 그동안 학습했던\n학습 내역과 리포트가 삭제되어 복구가 불가해요\n\n정말 탈퇴하시겠습니까?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA7A7A7),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          20,
        ).r,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 40.5,
              ).r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.02).r,
              ),
              backgroundColor: const Color(0xFF919191),
            ),
            child: Text(
              '더 공부할래요',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton(
            onPressed: onQuitPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 57,
              ).r,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.02).r,
              ),
              backgroundColor: const Color(0xFFFF6699),
            ),
            child: Text(
              '떠날래요',
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

  onQuitPressed() async {
    //TODO: 비밀번호 입력창 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1FCFE),
      body: Stack(
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
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 44,
              ).r,
              child: Text(
                '계정 관리',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          // TODO: 팝업 창 추가하기
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 156,
              ).r,
              child: FilledButton(
                onPressed: () => _showLogoutDialog(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 128,
                  ).r,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8).r,
                  ),
                  backgroundColor: const Color(0xFF1D2E0F),
                ),
                child: Text(
                  '로그아웃 하기',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 216,
              ).r,
              child: FilledButton(
                onPressed: () {
                  _showQuitDialog(context);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 128,
                  ).r,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8).r,
                  ),
                  backgroundColor: const Color(0xFF93E54C),
                ),
                child: Text(
                  '계정 탈퇴하기',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
