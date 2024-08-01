import 'package:block_english/utils/device_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegSelectRoleScreen extends StatelessWidget {
  const RegSelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Padding(
          padding: DeviceScale.scaffoldPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
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
                  Center(
                    child: Column(
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
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/reg_student_screen');
                      },
                      icon: SvgPicture.asset(
                        width: 180 * DeviceScale.scaleWidth(context),
                        height: 206 * DeviceScale.scaleHeight(context),
                        'assets/cards/sign_in_user.svg',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70 * DeviceScale.scaleWidth(context),
                  ),
                  SizedBox(
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/reg_super_screen');
                      },
                      icon: SvgPicture.asset(
                        width: 180 * DeviceScale.scaleWidth(context),
                        height: 206 * DeviceScale.scaleHeight(context),
                        'assets/cards/sign_in_manager.svg',
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}
