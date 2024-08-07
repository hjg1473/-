import 'package:block_english/services/user_service.dart';
import 'package:block_english/widgets/reg_input_box.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserChangePasswordScreen extends ConsumerStatefulWidget {
  const UserChangePasswordScreen({super.key});

  @override
  ConsumerState<UserChangePasswordScreen> createState() =>
      _UserChangePasswordScreenState();
}

class _UserChangePasswordScreenState
    extends ConsumerState<UserChangePasswordScreen> {
  String currentPassword = '';
  String newPassword = '';
  String newPassword2 = '';

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newPassword2Controller = TextEditingController();

  String currentPasswordError = '';
  String newPasswordError = '';
  String newPassword2Error = '';

  bool changeDisable = true;

  bool currentPasswordChecked = false;
  bool newPasswordChecked = false;
  bool currentPasswordObsecure = true;
  bool newPasswordObsecure = true;
  bool newPassword2Obsecure = true;

  onCurrentPasswordChanged() {
    currentPassword = currentPasswordController.text;
    if (currentPassword.length < 8) {
      setState(() {
        currentPasswordError = '비밀번호는 8자 이상이어야 합니다';
        currentPasswordChecked = false;
      });
    } else {
      setState(() {
        currentPasswordError = '';
        currentPasswordChecked = true;
        if (newPasswordChecked) {
          setState(() {
            changeDisable = false;
          });
        }
      });
    }
  }

  onNewPasswordChanged() {
    newPassword = newPasswordController.text;
    newPassword2 = newPassword2Controller.text;

    if (newPassword.length > 7 && newPassword2.isNotEmpty) {
      if (newPassword == newPassword2) {
        setState(() {
          newPasswordError = '';
          newPassword2Error = '';
          newPasswordChecked = true;
          if (currentPasswordChecked) {
            setState(() {
              changeDisable = false;
            });
          }
        });
      } else {
        setState(() {
          newPasswordError = '';
          newPassword2Error = '비밀번호가 일치하지 않습니다';
          newPasswordChecked = false;
          changeDisable = true;
        });
      }
    } else if (newPassword2.isEmpty) {
      setState(() {
        newPassword2Error = '';
        newPasswordChecked = false;
        changeDisable = true;
      });
    } else {
      setState(() {
        if (newPassword.length < 8) {
          newPasswordError = '비밀번호는 8자 이상이어야 합니다';
        } else {
          newPasswordError = '';
        }
        newPasswordChecked = false;
        changeDisable = true;
      });
    }
  }

  onEyePressed() {
    setState(() {
      currentPasswordObsecure = !currentPasswordObsecure;
    });
  }

  onEye1Pressed() {
    setState(() {
      newPasswordObsecure = !newPasswordObsecure;
    });
  }

  onEye2Pressed() {
    setState(() {
      newPassword2Obsecure = !newPassword2Obsecure;
    });
  }

  onChangePressed() async {
    // 비밀번호 변경 API 호출
    final response = await ref.watch(userServiceProvider).putUsersPassword(
          currentPassword,
          newPassword,
        );

    response.fold((failure) {
      if (failure.statusCode == 409) {
        setState(() {
          currentPasswordError = '현재 비밀번호가 틀렸습니다';
          currentPasswordChecked = false;
          changeDisable = true;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed ${failure.statusCode} : ${failure.detail}'),
          ),
        );
      }
    }, (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success.detail.toString()),
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            onPressed: () => Navigator.of(context).pop(),
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
                                  '비밀번호 변경',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '비밀번호를 재설정해 주세요',
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
                      const Spacer(flex: 3),
                      RegInputBox(
                        width: 684,
                        labelText: '현재 비밀번호',
                        hintText: '현재 비밀번호를 입력해 주세요',
                        controller: currentPasswordController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                        ],
                        errorMessage: currentPasswordError,
                        onChanged: onCurrentPasswordChanged,
                        obscureText: true,
                        isObsecure: currentPasswordObsecure,
                        onEyePressed: onEyePressed,
                      ),
                      SizedBox(height: 16.r),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RegInputBox(
                            labelText: '새 비밀번호',
                            hintText: '영문/숫자 조합, 8자 이상',
                            controller: newPasswordController,
                            errorMessage: newPasswordError,
                            onChanged: onNewPasswordChanged,
                            obscureText: true,
                            isObsecure: newPasswordObsecure,
                            onEyePressed: onEye1Pressed,
                          ),
                          RegInputBox(
                            labelText: '새 비밀번호 확인',
                            hintText: '새 비밀번호를 다시 입력해 주세요',
                            controller: newPassword2Controller,
                            errorMessage: newPassword2Error,
                            onChanged: onNewPasswordChanged,
                            obscureText: true,
                            isObsecure: newPassword2Obsecure,
                            onEyePressed: onEye2Pressed,
                          ),
                        ],
                      ),
                      const Spacer(flex: 5),
                    ],
                  ),
                ),
              ),
              SquareButton(
                text: '비밀번호 변경하기',
                onPressed: changeDisable ? null : onChangePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
