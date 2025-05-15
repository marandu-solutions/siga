import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SentimentPieChart extends StatelessWidget {
  final int positiveCount;
  final int negativeCount;

  const SentimentPieChart({
    Key? key,
    required this.positiveCount,
    required this.negativeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = positiveCount + negativeCount;

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 32,
          sectionsSpace: 4,
          sections: [
            PieChartSectionData(
              value: positiveCount.toDouble(),
              color: cs.secondary,
              radius: 48,
              title: total > 0
                  ? '${(positiveCount / total * 100).toStringAsFixed(0)}%'
                  : '0%',
              titleStyle: TextStyle(
                color: cs.onSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            PieChartSectionData(
              value: negativeCount.toDouble(),
              color: cs.error,
              radius: 48,
              title: total > 0
                  ? '${(negativeCount / total * 100).toStringAsFixed(0)}%'
                  : '0%',
              titleStyle: TextStyle(
                color: cs.onError,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
