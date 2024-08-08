import 'package:block_english/services/student_service.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentAddSuperScreen extends ConsumerStatefulWidget {
  const StudentAddSuperScreen({super.key});

  @override
  ConsumerState<StudentAddSuperScreen> createState() =>
      _StudentAddSuperScreenState();
}

class _StudentAddSuperScreenState extends ConsumerState<StudentAddSuperScreen> {
  String pincode = '';

  onPressed() async {
    final response = await ref
        .watch(studentServiceProvider)
        .postGroupEnter(int.parse(pincode));
    response.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${failure.statusCode}: ${failure.detail}'),
          ),
        );
      },
      (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success.detail),
          ),
        );
        if (success.detail == '연결되었습니다.') {
          Navigator.of(context).pop(true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: const Color(0xFFD1FCFE),
          body: SingleChildScrollView(
            child: SizedBox(
              height: 1.sh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 307.r,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 32,
                        left: 64,
                        right: 64,
                      ).r,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                icon: SvgPicture.asset(
                                  'assets/buttons/round_back_button.svg',
                                  width: 48.r,
                                  height: 48.r,
                                ),
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      '모니터링 관리자 추가',
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '모니터링 관리자를 추가하기 위해 PIN 코드를 입력해 주세요',
                                      style: TextStyle(
                                        fontSize: 14.r,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0x88000000),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(flex: 8),
                          SizedBox(
                            width: 428.r,
                            child: PinCodeFields(
                              length: 6,
                              fieldWidth: 62.r,
                              fieldHeight: 76.r,
                              fieldBorderStyle: FieldBorderStyle.square,
                              borderRadius: BorderRadius.circular(11.2).r,
                              borderColor: Colors.white,
                              activeBorderColor: Colors.white,
                              fieldBackgroundColor: Colors.white,
                              activeBackgroundColor: Colors.white,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              animationDuration:
                                  const Duration(milliseconds: 100),
                              autoHideKeyboard: true,
                              textStyle: TextStyle(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              onChange: (value) {
                                setState(() {
                                  pincode = value;
                                });
                              },
                              onComplete: (value) {
                                setState(() {
                                  pincode = value;
                                });
                              },
                            ),
                          ),
                          const Spacer(flex: 9),
                        ],
                      ),
                    ),
                  ),
                  SquareButton(
                    text: '추가하기',
                    onPressed: pincode.length == 6 ? onPressed : null,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
