import 'package:block_english/utils/color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({
    super.key,
    required this.width,
    required this.height,
    required this.data,
  });

  final double width;
  final double height;
  final List<double> data;

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartWidget> {
  int touchedIndex = -1;
  late List<double> sortedData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sortedData = List.from(widget.data)..sort((a, b) => b.compareTo(a));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (widget).width,
      height: (widget).height,
      child: PieChart(
        PieChartData(
          startDegreeOffset: 280,
          // pieTouchData: PieTouchData(
          //   touchCallback: (FlTouchEvent event, pieTouchResponse) {
          //     setState(() {
          //       if (!event.isInterestedForInteractions ||
          //           pieTouchResponse == null ||
          //           pieTouchResponse.touchedSection == null) {
          //         touchedIndex = -1;
          //         return;
          //       }
          //       touchedIndex =
          //           pieTouchResponse.touchedSection!.touchedSectionIndex;
          //     });
          //   },
          // ),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 1,
          centerSpaceRadius: (widget).width * 0.2,
          sections: showingSections(sortedData),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(List<double> data) {
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? (widget).width * 0.35 : (widget).width * 0.3;
      switch (i) {
        case 0:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryPink[500]!,
            value: data[0],
            radius: radius,
          );
        case 1:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryYellow[500]!,
            value: data[1],
            radius: radius,
          );
        case 2:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryGreen[500]!,
            value: data[2],
            radius: radius,
          );
        case 3:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryBlue[500]!,
            value: data[3],
            radius: radius,
          );
        case 4:
          return PieChartSectionData(
            showTitle: isTouched,
            color: primaryPurple[500]!,
            value: data[4],
            radius: radius,
          );
        default:
          throw Error();
      }
    });
  }
}
