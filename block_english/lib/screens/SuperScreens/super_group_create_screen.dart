import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperGroupCreateScreen extends ConsumerStatefulWidget {
  const SuperGroupCreateScreen({super.key});

  @override
  ConsumerState<SuperGroupCreateScreen> createState() =>
      _SuperGroupCreateScreenState();
}

class _SuperGroupCreateScreenState
    extends ConsumerState<SuperGroupCreateScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  void onCreateGroup() async {
    final String groupName = _groupNameController.text;
    final String detailText = _detailController.text;

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('그룹명을 입력해주세요'),
        ),
      );
      return;
    }

    final result =
        await ref.watch(superServiceProvider).postCreateGroup(groupName);
    debugPrint('result: $result');

    result.fold((failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('실패.. ${failure.detail}'),
          ),
        );
      }
    }, (success) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/super_main_screen',
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 32 * SizeConfig.scales,
              left: 64 * SizeConfig.scales,
              right: 64 * SizeConfig.scales,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
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
                SizedBox(
                  height: 48 * SizeConfig.scales,
                  child: Center(
                    child: Text(
                      '그룹 생성',
                      style: TextStyle(
                        fontSize: 22 * SizeConfig.scales,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 64 * SizeConfig.scales,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text.rich(
                        TextSpan(
                          text: '학습 그룹명 ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10 * SizeConfig.scales,
                      ),
                      Container(
                        width: 326 * SizeConfig.scales,
                        height: 48 * SizeConfig.scales,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _groupNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: '그룹의 이름을 설정해주세요',
                            hintStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD6D6D6),
                            ),
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                'assets/buttons/rounded_save_button.svg',
                                width: 49 * SizeConfig.scales,
                                height: 29 * SizeConfig.scales,
                              ),
                              //TODO: complete onPressed
                              onPressed: () {},
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '상세정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        height: 10 * SizeConfig.scales,
                      ),
                      Container(
                        width: 326 * SizeConfig.scales,
                        height: 48 * SizeConfig.scales,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _detailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: 'Ex) 빅드림 초등학교',
                            hintStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD6D6D6),
                            ),
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                'assets/buttons/rounded_save_button.svg',
                                width: 49 * SizeConfig.scales,
                                height: 29 * SizeConfig.scales,
                              ),
                              //TODO: complete onPressed
                              onPressed: () {},
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    debugPrint('first clicked');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: SizeConfig.fullWidth / 2,
                    height: 68 * SizeConfig.scales,
                    color: const Color(
                      0xFF6F6F6F,
                    ),
                    child: const Text(
                      '핀코드 바로 생성하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onCreateGroup,
                  child: Container(
                    alignment: Alignment.center,
                    width: SizeConfig.fullWidth / 2,
                    height: 68 * SizeConfig.scales,
                    color: const Color(
                      0xFF2C2C2C,
                    ),
                    child: const Text(
                      '그룹 생성하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
