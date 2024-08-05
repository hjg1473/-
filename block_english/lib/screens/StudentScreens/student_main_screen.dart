import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/size_config.dart';
import 'package:block_english/utils/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentMainScreen extends ConsumerWidget {
  const StudentMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 32 * SizeConfig.scales,
                  left: 44 * SizeConfig.scales,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: SvgPicture.asset(
                    'assets/buttons/round_back_button.svg',
                    width: 48 * SizeConfig.scales,
                    height: 48 * SizeConfig.scales,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: 32 * SizeConfig.scales,
                left: 342 * SizeConfig.scales,
              ),
              child: Stack(
                alignment: const Alignment(0.3, 0),
                children: [
                  SvgPicture.asset(
                    'assets/images/season_block.svg',
                    height: 45 * SizeConfig.scales,
                    width: 128 * SizeConfig.scales,
                  ),
                  Text(
                    seasonToString(ref.watch(statusProvider).season),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18 * SizeConfig.scales,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 115 * SizeConfig.scales),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/setting_screen'),
                    icon: SvgPicture.asset(
                      'assets/cards/student_main_1.svg',
                      width: 230 * SizeConfig.scales,
                      height: 207 * SizeConfig.scales,
                    ),
                  ),
                  SizedBox(
                    width: 6 * SizeConfig.scales,
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/cards/student_main_2.svg',
                      width: 205 * SizeConfig.scales,
                      height: 207 * SizeConfig.scales,
                    ),
                  ),
                  SizedBox(
                    width: 6 * SizeConfig.scales,
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    icon: SvgPicture.asset('assets/cards/student_main_3.svg',
                        width: 205 * SizeConfig.scales,
                        height: 207 * SizeConfig.scales),
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
