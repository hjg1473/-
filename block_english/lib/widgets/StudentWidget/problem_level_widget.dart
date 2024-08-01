import 'package:flutter/cupertino.dart';

class ProblemLevelWidget extends StatelessWidget {
  const ProblemLevelWidget({super.key, required this.levelName});

  final String levelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: double.minPositive,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: const Color(0xFFC4C4C4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                'assets/images/test.png',
              ),
            ),
            Text(
              levelName,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
