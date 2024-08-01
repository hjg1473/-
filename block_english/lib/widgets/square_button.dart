import 'package:block_english/utils/device_scale.dart';
import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  const SquareButton({
    super.key,
    required this.text,
    this.backgroundColor = Colors.black,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize:
            Size(double.infinity, DeviceScale.squareButtonHeight(context)),
        backgroundColor: backgroundColor,
        shape: const BeveledRectangleBorder(),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
