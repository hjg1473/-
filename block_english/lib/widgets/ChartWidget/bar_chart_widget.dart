import 'dart:async';
import 'dart:math';
import 'package:block_english/utils/color.dart';
import 'package:block_english/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BarChartWidget extends StatefulWidget {
  BarChartWidget({super.key, required this.data});

  final List<double> data;

  List<Color> get availableColors => <Color>[
        primaryBlue[500]!,
        primaryPink[500]!,
        primaryGreen[500]!,
      ];

  final Color barBackgroundColor = Colors.transparent;
  final Color barColor = primaryPurple[500]!;
  final Color touchedBarColor = primaryBlue[500]!;

  @override
  State<StatefulWidget> createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Build되자마자 isPlaying을 true로 설정
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        refreshState();
      }
    });

    // 1.2초 후에 isPlaying을 false로 설정
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          isPlaying = !isPlaying;
          if (isPlaying) {
            refreshState();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.r,
      height: 112.5.r,
      child: Stack(
        children: <Widget>[
          Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: BarChart(
                  isPlaying ? randomData() : mainBarData(widget.data),
                  swapAnimationDuration: animDuration,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 24,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? widget.touchedBarColor : barColor,
          width: width.r,
          borderSide: isTouched
              ? BorderSide(color: widget.touchedBarColor)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups(List<double> data) =>
      List.generate(3, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, data.isEmpty ? 0 : 100 - data[i],
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, data.length < 2 ? 0 : 100 - data[i],
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, data.length < 3 ? 0 : 100 - data[i],
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData(List<double> data) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => primaryBlue[600]!,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String index;
            switch (group.x) {
              case 0:
                index = levelList[0];
                break;
              case 1:
                index = levelList[1];
                break;
              case 2:
                index = levelList[2];
                break;
              default:
                throw Error();
            }
            return BarTooltipItem(
              '$index\n',
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: TextStyle(
                    color: Colors.white, //widget.touchedBarColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getLeftTitles,
            reservedSize: 45.r,
            interval: 25,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(data),
      gridData: const FlGridData(
        show: true,
        horizontalInterval: 25,
        verticalInterval: 1,
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 11.sp,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(levelList[0], style: style);
        break;
      case 1:
        text = Text(levelList[1], style: style);
        break;
      case 2:
        text = Text(levelList[2], style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 11.sp,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(' 0%  ', style: style);
        break;
      case 50:
        text = Text('50% ', style: style);
        break;
      case 100:
        text = Text('100%', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getLeftTitles,
            reservedSize: 45.r,
            interval: 25,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(3, (i) {
        switch (i) {
          case 0:
            return makeGroupData(
              0,
              Random().nextInt(75).toDouble() + 16,
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          case 1:
            return makeGroupData(
              1,
              Random().nextInt(75).toDouble() + 16,
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          case 2:
            return makeGroupData(
              2,
              Random().nextInt(75).toDouble() + 16,
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );

          default:
            return throw Error();
        }
      }),
      gridData: const FlGridData(
        show: true,
        horizontalInterval: 25,
        verticalInterval: 1,
      ),
    );
  }

  Future<dynamic> refreshState() async {
    if (!mounted) return;
    setState(() {});
    await Future<dynamic>.delayed(
      animDuration + const Duration(milliseconds: 50),
    );
    if (isPlaying && mounted) {
      await refreshState();
    }
  }
}
