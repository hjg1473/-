import 'package:block_english/screens/SuperScreens/super_monitor_group_screen.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/GroupWidget/pin_code_widget.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
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

  int groupId = 0;

  String savedName = '';
  String savedDetail = '';

  bool pinCodeExist = false;
  bool pinCodeExpired = false;
  String _pinCode = '';
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;

  late Throttle _throttle;

  @override
  void initState() {
    super.initState();
    _groupNameController.text = widget.groupName;
    savedName = widget.groupName;
    _detailController.text = widget.detailText;
    savedDetail = widget.detailText;
    groupId = widget.groupId;
    _throttle = Throttle<String>(
      const Duration(milliseconds: 5000),
      initialValue: '',
      checkEquality: false,
    )..values.listen((_) => onPinGeneratePressed());
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  onSavePressed() async {
    final result = await ref.watch(superServiceProvider).putGroupUpdate(
          groupId,
          _groupNameController.text,
          _detailController.text,
        );

    result.fold((failure) {
      //TODO: error handling
    }, (response) {
      //TODO: show success dialog
      savedName = _groupNameController.text;
      savedDetail = _detailController.text;
    });
  }

  onPinGeneratePressed() async {
    final result =
        await ref.watch(superServiceProvider).postPinNumber(widget.groupId);

    result.fold((failure) {
      //TODO: error handling
      debugPrint('[SUPER_GROUP_SETTING_SCREEN] onPinGenerated error');
      debugPrint(
          '[ERROR] code: ${failure.statusCode} detail: ${failure.detail}');
    }, (pinModel) {
      _ticker ??= createTicker((elapsed) {
        setState(() {
          _elapsed = elapsed;

          if (_elapsed.inSeconds >= 180) {
            pinCodeExpired = true;
            _ticker!.stop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ],
              ),
              SizedBox(
                height: 14.r,
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
                        color: const Color(0xFFDFDFDF),
                        borderRadius: BorderRadius.circular(8.0).r,
                      ),
                      padding: const EdgeInsets.all(16).r,
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
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  width: 280.r,
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
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                                        color: const Color(0xFFD6D6D6),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.r),
                          SizedBox(
                            width: 280.r,
                            height: 78.r,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '상세 정보',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  width: 280.r,
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
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                                        color: const Color(0xFFD6D6D6),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
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
                              height: 38.r,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A4949),
                                borderRadius: BorderRadius.circular(8.0).r,
                              ),
                              child: Text(
                                '저장하기',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
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
                        color: const Color(0xFFDFDFDF),
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
                                    _throttle.setValue(_pinCode);
                                  }
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              width: 320.r,
                              height: 38.r,
                              decoration: BoxDecoration(
                                color: pinCodeExist && !pinCodeExpired
                                    ? Colors.grey[200]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8.0).r,
                                boxShadow: [
                                  if (pinCodeExpired || !pinCodeExist)
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: const Offset(0, 0),
                                    ),
                                ],
                              ),
                              child: Text(
                                pinCodeExist && pinCodeExpired
                                    ? 'PIN 코드 재생성하기 '
                                    : 'PIN 코드 생성하기',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
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
