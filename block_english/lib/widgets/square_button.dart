import 'package:block_english/utils/size_config.dart';
import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final bool disable;

  const SquareButton({
    super.key,
    required this.text,
    this.backgroundColor = Colors.black,
    this.onPressed,
    this.disable = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.fullWidth,
      height: 68 * SizeConfig.scaleHeight,
      child: FilledButton(
        onPressed: disable ? null : onPressed,
        style: FilledButton.styleFrom(
          disabledBackgroundColor: const Color(0xFF727272),
          backgroundColor: backgroundColor,
          shape: const BeveledRectangleBorder(),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
