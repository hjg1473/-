import 'package:block_english/utils/size_config.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperMainScreen extends ConsumerWidget {
  const SuperMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  top: 29 * SizeConfig.scales,
                  right: 44 * SizeConfig.scales,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ref.watch(statusProvider).name} 님',
                          style: TextStyle(
                            fontSize: 15 * SizeConfig.scales,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '안녕하세요!',
                          style: TextStyle(
                            fontSize: 15 * SizeConfig.scales,
                            fontWeight: FontWeight.w500,
                            color: const Color(0x88000000),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 11 * SizeConfig.scales,
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed('/setting_screen'),
                      child: ClipOval(
                        child: Container(
                          color: Colors.amber,
                          width: 48 * SizeConfig.scales,
                          height: 48 * SizeConfig.scales,
                        ),
                      ),
                    )
                  ],
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
