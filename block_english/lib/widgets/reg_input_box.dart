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
  final bool obscureText;
  final bool isSelected;
  final VoidCallback? checkPressed;
  final VoidCallback? eyePressed;

  const RegInputBox({
    super.key,
    this.width = 300,
    this.height = 70,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.inputFormatters,
    this.errorMessage = '',
    this.obscureText = false,
    this.isSelected = false,
    this.checkPressed,
    this.eyePressed,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: labelText == '전화번호'
                  ? (width - 40) * 0.71
                  : (width - 40) * 0.75,
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
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  errorMessage,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 11),
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
            labelText == '전화번호'
                ? FilledButton(
                    onPressed: checkPressed,
                    style: FilledButton.styleFrom(
                      fixedSize: const Size(65, 35),
                      padding: const EdgeInsets.all(0),
                      backgroundColor: Colors.grey[600],
                    ),
                    child: const Text(
                      '중복확인',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  )
                : labelText == '비밀번호' || labelText == '비밀번호 확인'
                    ? SizedBox(
                        width: 30,
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          isSelected: isSelected,
                          icon: const Icon(Icons.visibility_off_outlined),
                          selectedIcon: const Icon(Icons.visibility_outlined),
                          iconSize: 25,
                          color: Colors.grey,
                          onPressed: eyePressed,
                        ),
                      )
                    : const SizedBox(width: 1),
          ],
        ),
      ),
    );
  }
}
