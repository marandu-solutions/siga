import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PerformanceLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Linha da semana atual
            LineChartBarData(
              spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 6), FlSpot(6, 7)],
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(0.3), Colors.transparent])),
            ),
            // Linha da semana anterior (tracejada)
            LineChartBarData(
              spots: const [FlSpot(0, 2), FlSpot(1, 2.5), FlSpot(2, 3), FlSpot(3, 4), FlSpot(4, 4.5), FlSpot(5, 5), FlSpot(6, 6)],
              isCurved: true,
              color: theme.colorScheme.onSurfaceVariant,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }
}