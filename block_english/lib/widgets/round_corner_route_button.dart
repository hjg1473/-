import 'package:block_english/utils/constants.dart';
import 'package:flutter/material.dart';

class RoundCornerRouteButton extends StatelessWidget {
  const RoundCornerRouteButton({
    super.key,
    required this.text,
    required this.routeName,
    required this.width,
    required this.heigth,
    required this.type,
    required this.remove,
  });

  final String text;
  final String routeName;
  final double width;
  final double heigth;
  final ButtonType type;
  final bool remove;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ButtonType.filled => FilledButton(
          onPressed: () {
            remove
                ? Navigator.of(context).pushNamedAndRemoveUntil(
                    routeName, (Route<dynamic> route) => false)
                : Navigator.of(context).pushNamed(routeName);
          },
          style: FilledButton.styleFrom(minimumSize: const Size(313, 45)),
          child: (Text(text)),
        ),
      ButtonType.outlined => OutlinedButton(
          onPressed: () {
            remove
                ? Navigator.of(context).pushNamedAndRemoveUntil(
                    routeName, (Route<dynamic> route) => false)
                : Navigator.of(context).pushNamed(routeName);
          },
          style: OutlinedButton.styleFrom(minimumSize: const Size(313, 45)),
          child: (Text(text)),
        ),
    };
  }
}
