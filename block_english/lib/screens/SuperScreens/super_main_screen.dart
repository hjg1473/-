import 'package:block_english/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperMainScreen extends StatelessWidget {
  const SuperMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 33 * SizeConfig.scales),
                child: SvgPicture.asset('assets/images/LOGO.svg'),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 23 * SizeConfig.scales,
                  right: 44 * SizeConfig.scales,
                ),
                child: const SizedBox(
                  height: 60,
                  width: 128,
                  child: Row(
                    children: [
                      Text('안녕하세요!'),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/super_monitor_screen'),
                    icon: SvgPicture.asset(
                      'assets/cards/super_main_1.svg',
                      width: 326 * SizeConfig.scales,
                      height: 207 * SizeConfig.scales,
                    ),
                  ),
                  SizedBox(
                    width: 12 * SizeConfig.scales,
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/setting_screen'),
                    icon: SvgPicture.asset(
                      'assets/cards/super_main_2.svg',
                      width: 326 * SizeConfig.scales,
                      height: 207 * SizeConfig.scales,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
