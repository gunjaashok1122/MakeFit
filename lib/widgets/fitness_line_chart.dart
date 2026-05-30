import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class FitnessLineChart extends StatelessWidget {
  final List<double> spots; // Y-values
  final List<String> xLabels; // X-axis names
  final Color lineColor;
  final List<Color> gradientColors;
  final double? minY;
  final double? maxY;
  final String tooltipSuffix;

  const FitnessLineChart({
    Key? key,
    required this.spots,
    required this.xLabels,
    this.lineColor = AppTheme.neonPurple,
    this.gradientColors = const [AppTheme.deepPurple, AppTheme.neonPurple],
    this.minY,
    this.maxY,
    this.tooltipSuffix = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const Center(
        child: Text(
          'No activity logs yet',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    final double determinedMinY = minY ?? 0;
    final double determinedMaxY = maxY ??
        (spots.reduce((a, b) => a > b ? a : b) * 1.15); // Add 15% padding on top

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.textMuted.withOpacity(0.12),
                strokeWidth: 1,
              );
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (determinedMaxY - determinedMinY) / 3,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                reservedSize: 32,
              ),
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
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: determinedMinY,
          maxY: determinedMaxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppTheme.cardNavyLight,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    '${barSpot.y.toInt()}$tooltipSuffix',
                    const TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                spots.length,
                (index) => FlSpot(index.toDouble(), spots[index]),
              ),
              isCurved: true,
              color: lineColor,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4.5,
                    color: lineColor,
                    strokeWidth: 2,
                    strokeColor: AppTheme.textWhite,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.25))
                      .toList(),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
