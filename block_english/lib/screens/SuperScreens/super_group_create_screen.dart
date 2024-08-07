import 'package:block_english/services/super_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    final result = await ref
        .watch(superServiceProvider)
        .postCreateGroup(groupName, detailText);
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
        Navigator.of(context).pop(true);
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
              top: 32.r,
              left: 64.r,
              right: 64.r,
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
                      width: 48.r,
                      height: 48.r,
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.r,
                  child: Center(
                    child: Text(
                      '그룹 생성',
                      style: TextStyle(
                        fontSize: 22.sp,
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
              horizontal: 64.r,
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
                      Text.rich(
                        TextSpan(
                          text: '학습 그룹명 ',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                          children: const [
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
                        height: 10.r,
                      ),
                      Container(
                        width: 326.r,
                        height: 48.r,
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
                              borderRadius: BorderRadius.circular(8.0).w,
                            ),
                            hintText: '그룹의 이름을 설정해주세요',
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD6D6D6),
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
                      Text(
                        '상세정보',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        height: 10.r,
                      ),
                      Container(
                        width: 326.r,
                        height: 48.r,
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
                              borderRadius: BorderRadius.circular(8.0).w,
                            ),
                            hintText: 'Ex) 빅드림 초등학교',
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD6D6D6),
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
                    width: 0.5.sw,
                    height: 68.r,
                    color: const Color(
                      0xFF6F6F6F,
                    ),
                    child: Text(
                      '핀코드 바로 생성하기',
                      style: TextStyle(
                        fontSize: 16.sp,
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
                    width: 0.5.sw,
                    height: 68.r,
                    color: const Color(
                      0xFF2C2C2C,
                    ),
                    child: Text(
                      '그룹 생성하기',
                      style: TextStyle(
                        fontSize: 16.sp,
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
