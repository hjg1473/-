import 'dart:async';

import 'package:block_english/screens/SuperScreens/super_monitor_group_screen.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/color.dart';
import 'package:block_english/utils/text_style.dart';
import 'package:block_english/widgets/GroupWidget/pin_code_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupSettingScreen extends ConsumerStatefulWidget {
  const GroupSettingScreen({
    super.key,
    required this.groupName,
    required this.detailText,
    required this.groupId,
  });

  final String groupName;
  final String detailText;
  final int groupId;

  @override
  ConsumerState<GroupSettingScreen> createState() => _GroupSettingScreenState();
}

class _GroupSettingScreenState extends ConsumerState<GroupSettingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  late StreamController<bool> _btnController;

  int groupId = 0;

  String savedName = '';
  String savedDetail = '';

  bool pinCodeExist = false;
  bool pinCodeExpired = false;
  String _pinCode = '';
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _groupNameController.text = widget.groupName;
    savedName = widget.groupName;
    _detailController.text = widget.detailText;
    savedDetail = widget.detailText;
    groupId = widget.groupId;
    _btnController = StreamController<bool>();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _detailController.dispose();
    _btnController.close();
    _ticker?.dispose();
    super.dispose();
  }

  onSavePressed() async {
    debugPrint('onSavePressed');
    final result = await ref.watch(superServiceProvider).putGroupUpdate(
          groupId,
          _groupNameController.text,
          _detailController.text,
        );

    result.fold((failure) {
      //TODO: error handling
      debugPrint('[SUPER_GROUP_SETTING_SCREEN] onSavePressed error: $failure');
    }, (response) {
      //TODO: show success dialog
      savedName = _groupNameController.text;
      savedDetail = _detailController.text;
    });
  }

  onPinGeneratePressed() async {
    if (_btnController.isClosed) return;
    _btnController.add(false);

    final result =
        await ref.watch(superServiceProvider).postPinNumber(widget.groupId);

    result.fold((failure) {
      //TODO: error handling
      debugPrint('[SUPER_GROUP_SETTING_SCREEN] onPinGenerated error');
      debugPrint(
          '[ERROR] code: ${failure.statusCode} detail: ${failure.detail}');

      if (_btnController.isClosed) return;
      _btnController.add(true);
    }, (pinModel) {
      _ticker ??= createTicker((elapsed) {
        setState(() {
          _elapsed = elapsed;

          if (_elapsed.inSeconds >= 180) {
            pinCodeExpired = true;
            _ticker!.stop();
            if (_btnController.isClosed) return;
            _btnController.add(true);
          }
        });
      });

      setState(() {
        _pinCode = pinModel.groupPinNumber!;
        pinCodeExist = true;
        pinCodeExpired = false;
      });

      _elapsed = Duration.zero;
      if (!_ticker!.isActive) {
        _ticker!.start();
      }

      debugPrint('[PINCODE] $_pinCode');
    });
  }

  onDeletePressed() async {
    debugPrint(widget.groupId.toString());
    final result =
        await ref.watch(superServiceProvider).deleteRemoveGroup(widget.groupId);

    result.fold((failure) {
      debugPrint('[SUPER_GROUP_SETTING_SCREEN] onDeletePressed error');
    }, (success) {
      Navigator.of(context).pop(true);
      Navigator.of(context)
          .popUntil(ModalRoute.withName('/super_monitor_screen'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E7FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 64,
            vertical: 32,
          ).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (savedName != _groupNameController.text ||
                            savedDetail != _detailController.text) {
                          // TODO: show alertDialog
                          return;
                        }

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => MonitorGroupScreen(
                              groupName: savedName,
                              detailText: savedDetail,
                              groupId: groupId,
                            ),
                          ),
                          ModalRoute.withName('/super_monitor_screen'),
                        );
                      },
                      icon: SvgPicture.asset(
                        'assets/buttons/round_back_button.svg',
                        width: 48.r,
                        height: 48.r,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '그룹 설정',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: onDeletePressed,
                      child: Text(
                        '그룹 삭제하기',
                        style: textStyle14.copyWith(
                          color: const Color(0xFF373737),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12.r,
              ),
              SizedBox(
                width: 684.r,
                height: 258.r,
                child: Row(
                  children: [
                    Container(
                      width: 312.r,
                      height: 258.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0).r,
                      ),
                      padding: const EdgeInsets.all(15).r,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 280.r,
                            height: 78.r,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '그룹명 변경',
                                  style: textStyle16,
                                ),
                                SizedBox(
                                  width: 280.r,
                                  height: 48.r,
                                  child: TextField(
                                    controller: _groupNameController,
                                    style: textStyle16,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0).w,
                                      ),
                                      hintText: '그룹의 이름을 설정해주세요',
                                      hintStyle: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF0F0F0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.r),
                          SizedBox(
                            width: 280.r,
                            height: 78.r,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '상세 정보',
                                  style: textStyle16,
                                ),
                                SizedBox(
                                  width: 280.r,
                                  height: 48.r,
                                  child: TextField(
                                    controller: _detailController,
                                    style: textStyle16,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0).w,
                                      ),
                                      hintText: '그룹의 상세정보를 입력해주세요',
                                      hintStyle: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF0F0F0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16.r,
                          ),
                          GestureDetector(
                            onTap: onSavePressed,
                            child: Container(
                              alignment: Alignment.center,
                              width: 280.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: primaryPurple[500],
                                borderRadius: BorderRadius.circular(8.0).r,
                              ),
                              child: Text(
                                '저장하기',
                                style: textStyle16.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20.r,
                    ),
                    Container(
                      width: 352.r,
                      height: 258.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0).r,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ).r,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: (pinCodeExpired || !pinCodeExist)
                                ? () {
                                    onPinGeneratePressed();
                                  }
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              width: 320.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8.0).r,
                              ),
                              child: Text(
                                pinCodeExist && pinCodeExpired
                                    ? 'PIN 코드 재생성하기 '
                                    : 'PIN 코드 생성하기',
                                style: textStyle16.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (pinCodeExist)
                            PinCodeWidget(
                              pinCode: _pinCode,
                              onButtonClicked: () {
                                setState(() {
                                  _ticker!.stop();
                                  pinCodeExist = false;
                                });
                              },
                              elapsed: _elapsed,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
