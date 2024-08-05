import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegInputBox extends StatelessWidget {
  final double width;
  final double height;
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final String errorMessage;
  final bool doubleCheck;
  final bool verify;
  final bool obscureText;
  final bool isSelected;
  final VoidCallback? onCheckPressed;
  final VoidCallback? onEyePressed;
  final bool success;

  const RegInputBox({
    super.key,
    this.width = 332,
    this.height = 64,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.inputFormatters,
    this.errorMessage = '',
    this.doubleCheck = false,
    this.verify = false,
    this.obscureText = false,
    this.isSelected = false,
    this.onCheckPressed,
    this.onEyePressed,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.r,
      height: height.r,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12.r,
        vertical: 8.r,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: doubleCheck || verify
                ? (width - 40) * 0.71
                : (width - 40) * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelText,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    errorMessage != ''
                        ? Row(
                            children: [
                              SizedBox(width: 10.w),
                              Icon(
                                Icons.error_outline,
                                color: success ? Colors.green : Colors.red,
                                size: 12.r,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                errorMessage,
                                style: TextStyle(
                                  color: success ? Colors.green : Colors.red,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(width: 1),
                  ],
                ),
                TextField(
                  inputFormatters: inputFormatters,
                  obscureText: isSelected,
                  obscuringCharacter: '*',
                  controller: controller,
                  cursorHeight: 20,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: hintText,
                    hintStyle:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          doubleCheck || verify
              ? FilledButton(
                  onPressed: onCheckPressed,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.r,
                      vertical: 10.r,
                    ),
                    backgroundColor: const Color(0xFF5D5D5D),
                  ),
                  child: Text(
                    doubleCheck ? '중복확인' : '인증번호 확인',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              : obscureText
                  ? SizedBox(
                      width: 25.r,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: isSelected
                            ? const Icon(Icons.visibility_off_outlined)
                            : const Icon(Icons.visibility),
                        iconSize: 25.r,
                        color: const Color(0xFF585858),
                        onPressed: onEyePressed,
                      ),
                    )
                  : const SizedBox(width: 1),
        ],
      ),
    );
  }
}
