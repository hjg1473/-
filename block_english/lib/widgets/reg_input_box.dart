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
    this.width = 300,
    this.height = 70,
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
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                      Text(labelText),
                      errorMessage != ''
                          ? Row(
                              children: [
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.error_outline,
                                  color: success ? Colors.blue : Colors.red,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  errorMessage,
                                  style: TextStyle(
                                      color: success ? Colors.blue : Colors.red,
                                      fontSize: 11),
                                ),
                              ],
                            )
                          : const SizedBox(width: 1),
                    ],
                  ),
                  TextField(
                    inputFormatters: inputFormatters,
                    obscureText: obscureText,
                    controller: controller,
                    cursorHeight: 20,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      hintText: hintText,
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
                      minimumSize: const Size(double.minPositive, 35),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      backgroundColor: Colors.grey[600],
                    ),
                    child: Text(
                      doubleCheck ? '중복확인' : '인증번호 확인',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  )
                : labelText == '비밀번호' || labelText == '비밀번호 확인'
                    ? SizedBox(
                        width: 25,
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          isSelected: isSelected,
                          icon: const Icon(Icons.visibility_off_outlined),
                          selectedIcon: const Icon(Icons.visibility_outlined),
                          iconSize: 25,
                          color: Colors.grey,
                          onPressed: onEyePressed,
                        ),
                      )
                    : const SizedBox(width: 1),
          ],
        ),
      ),
    );
  }
}
