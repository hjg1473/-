import 'package:block_english/utils/color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170.r,
      height: 170.r,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 1,
          centerSpaceRadius: 171.r * 0.2,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(5, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 171.r * 0.35 : 171.r * 0.3;
      switch (i) {
        case 0:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryPink[500]!,
            value: 20,
            radius: radius,
          );
        case 1:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryYellow[500]!,
            value: 20,
            radius: radius,
          );
        case 2:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryGreen[500]!,
            value: 20,
            radius: radius,
          );
        case 3:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryBlue[500]!,
            value: 20,
            radius: radius,
          );
        case 4:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryPurple[500]!,
            value: 20,
            radius: radius,
          );
        default:
          throw Error();
      }
    });
  }
}
