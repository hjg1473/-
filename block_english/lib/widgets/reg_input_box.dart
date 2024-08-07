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
  final bool dupCheck;
  final bool obscureText;
  final bool isObsecure;
  final VoidCallback? onChanged;
  final VoidCallback? onCheckChanged;
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
    this.dupCheck = false,
    this.obscureText = false,
    this.isObsecure = false,
    this.onChanged,
    this.onCheckChanged,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8).w,
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
            width: dupCheck ? (width - 36 - 71).r : (width - 36 - 25).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              SizedBox(width: 10.r),
                              Icon(
                                Icons.error_outline,
                                color: success ? Colors.green : Colors.red,
                                size: 12.r,
                              ),
                              SizedBox(width: 6.r),
                              Text(
                                errorMessage,
                                style: TextStyle(
                                  color: success ? Colors.green : Colors.red,
                                  fontSize: 11.r,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(width: 1),
                  ],
                ),
                TextField(
                  onChanged: (value) {
                    if (onChanged != null) {
                      onChanged!();
                    }
                  },
                  inputFormatters: inputFormatters,
                  obscureText: isObsecure,
                  obscuringCharacter: '*',
                  controller: controller,
                  cursorHeight: 13,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          dupCheck
              ? FilledButton(
                  onPressed: onCheckPressed,
                  style: FilledButton.styleFrom(
                    minimumSize: Size(71.r, 36.r),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.r,
                      vertical: 10.r,
                    ),
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFFAFAFAF),
                  ),
                  child: Text(
                    '중복확인',
                    style: TextStyle(
                      fontSize: 14.sp,
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
                        icon: isObsecure
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
