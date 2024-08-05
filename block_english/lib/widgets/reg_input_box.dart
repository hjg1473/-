import 'package:block_english/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      width: width * SizeConfig.scales,
      height: height * SizeConfig.scales,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * SizeConfig.scales,
        vertical: 8 * SizeConfig.scales,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: (width - 36 - 71) * SizeConfig.scales,
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
                        fontSize: 13 * SizeConfig.scales,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    errorMessage != ''
                        ? Row(
                            children: [
                              SizedBox(width: 10 * SizeConfig.scales),
                              Icon(
                                Icons.error_outline,
                                color: success ? Colors.green : Colors.red,
                                size: 12 * SizeConfig.scales,
                              ),
                              SizedBox(width: 6 * SizeConfig.scales),
                              Text(
                                errorMessage,
                                style: TextStyle(
                                  color: success ? Colors.green : Colors.red,
                                  fontSize: 11 * SizeConfig.scales,
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
                  cursorHeight: 13,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: hintText,
                    hintStyle: TextStyle(
                        fontSize: 13 * SizeConfig.scales,
                        fontWeight: FontWeight.w400),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          doubleCheck
              ? FilledButton(
                  onPressed: onCheckPressed,
                  style: FilledButton.styleFrom(
                    minimumSize:
                        Size(71 * SizeConfig.scales, 36 * SizeConfig.scales),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * SizeConfig.scales,
                      vertical: 10 * SizeConfig.scales,
                    ),
                    backgroundColor: const Color(0xFF5D5D5D),
                  ),
                  child: Text(
                    '중복확인',
                    style: TextStyle(
                      fontSize: 14 * SizeConfig.scales,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              : obscureText
                  ? SizedBox(
                      width: 25 * SizeConfig.scales,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: isSelected
                            ? const Icon(Icons.visibility_off_outlined)
                            : const Icon(Icons.visibility),
                        iconSize: 25 * SizeConfig.scales,
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
