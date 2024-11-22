import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/GroupWidget/pin_code_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ParentAddChildScreen extends ConsumerStatefulWidget {
  const ParentAddChildScreen({super.key});

  @override
  ConsumerState<ParentAddChildScreen> createState() =>
      _ParentAddChildScreenState();
}

class _ParentAddChildScreenState extends ConsumerState<ParentAddChildScreen>
    with SingleTickerProviderStateMixin {
  bool pinCodeExists = false;
  bool pinCodeExpired = false;
  String _pinCode = '';
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;

  onPinGeneratePressed() async {
    final result = await ref.watch(superServiceProvider).getParentPinNumber();

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
        _pinCode = pinModel.parentPinNumber!;
        pinCodeExpired = false;
        pinCodeExists = true;
      });

      _elapsed = Duration.zero;
      if (!_ticker!.isActive) {
        _ticker!.start();
      }

      debugPrint('[PINCODE] $_pinCode');
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    onPinGeneratePressed();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _ticker?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E7FF),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 64,
          right: 64,
          top: 32,
        ).r,
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
                  '학습자 추가',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 62.r,
              left: 141.r,
              child: Container(
                width: 403.r,
                height: 242.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0).r,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton(
                      onPressed: onPinGeneratePressed,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(363.r, 44.r),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7).r,
                        ),
                      ),
                      child: Text(
                        'PIN 코드 재생성하기',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (pinCodeExists)
                      PinCodeWidget(
                        onButtonClicked: () {
                          setState(() {
                            _ticker!.stop();
                            pinCodeExists = false;
                          });
                        },
                        pinCode: _pinCode,
                        elapsed: _elapsed,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
