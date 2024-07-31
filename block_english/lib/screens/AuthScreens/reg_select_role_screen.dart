import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegSelectRoleScreen extends StatelessWidget {
  const RegSelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: const Text(
                        '로그인',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.minPositive, 40),
                        backgroundColor: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        const Text(
                          '나는 어떤 사용자인가요?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '본인의 신분에 맞게 선택해주세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    //TODO: 정렬 맞추기
                    const SizedBox(width: 100),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 206,
                      child: IconButton(
                        onPressed: null,
                        icon: SvgPicture.asset(
                          'assets/cards/sign_in_user.svg',
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    SizedBox(
                      width: 180,
                      height: 206,
                      child: IconButton(
                        onPressed: null,
                        icon: SvgPicture.asset(
                          'assets/cards/sign_in_manager.svg',
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
