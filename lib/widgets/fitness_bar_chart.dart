import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material';
import '../themes/app_theme.dart';

class FitnessBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> xLabels;
  final Gradient barGradient;
  final double? maxVal;

  const FitnessBarChart({
    Key? key,
    required this.values,
    required this.xLabels,
    this.barGradient = AppTheme.primaryGradient,
    this.maxVal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const Center(
        child: Text(
          'No activity logs yet',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    final double determinedMaxY = maxVal ?? 
        (values.reduce((a, b) => a > b ? a : b) * 1.15);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  if (index >= 0 && index < xLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        xLabels[index],
                        style: const TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 24,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: determinedMaxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppTheme.cardNavyLight,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(
            values.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  gradient: barGradient,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: determinedMaxY,
                    color: AppTheme.cardNavyLight.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
