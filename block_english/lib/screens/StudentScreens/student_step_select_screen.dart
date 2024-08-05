import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentStepSelectScreen extends ConsumerStatefulWidget {
  const StudentStepSelectScreen({super.key});

  @override
  ConsumerState<StudentStepSelectScreen> createState() =>
      _StudentStepSelectScreenState();
}

class _StudentStepSelectScreenState
    extends ConsumerState<StudentStepSelectScreen> {
  int selectedLevel = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 32 * SizeConfig.scales,
              left: 44 * SizeConfig.scales,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                icon: SvgPicture.asset(
                  'assets/buttons/labeled_back_button.svg',
                  width: 133 * SizeConfig.scales,
                  height: 44 * SizeConfig.scales,
                ),
              ),
            ),
            Positioned(
              top: 36 * SizeConfig.scales,
              left: 324 * SizeConfig.scales,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF93E54C),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0 * SizeConfig.scales,
                      vertical: 10.0 * SizeConfig.scales,
                    ),
                    child: Text(
                      levellist[selectedLevel],
                      style: TextStyle(
                        fontSize: 14 * SizeConfig.scales,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10 * SizeConfig.scales,
                  ),
                  Text(
                    'Level ${selectedLevel + 1}',
                    style: TextStyle(
                      fontSize: 22 * SizeConfig.scales,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Center(
              child: Text('data'),
            ),
          ],
        ),
      ),
    );
  }
}
