import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SentimentPieChart extends StatefulWidget {
  final int positiveCount;
  final int negativeCount;

  const SentimentPieChart({
    Key? key,
    required this.positiveCount,
    required this.negativeCount,
  }) : super(key: key);

  @override
  State<SentimentPieChart> createState() => _SentimentPieChartState();
}

class _SentimentPieChartState extends State<SentimentPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final total = widget.positiveCount + widget.negativeCount;

    if (total == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: cs.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text('Nenhum feedback ainda', style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            // Proporção ajustada para dar mais espaço à legenda
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
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
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    centerSpaceRadius: 40,
                    sectionsSpace: 4,
                    sections: [
                      _buildSection(isTouched: touchedIndex == 0, value: widget.positiveCount.toDouble(), color: cs.secondary, onColor: cs.onSecondary, total: total),
                      _buildSection(isTouched: touchedIndex == 1, value: widget.negativeCount.toDouble(), color: cs.error, onColor: cs.onError, total: total),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$total', style: textTheme.headlineSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold)),
                    Text('Total', style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          // Legenda
          Expanded(
            // Proporção ajustada
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegend(color: cs.secondary, text: 'Positivos', value: widget.positiveCount),
                const SizedBox(height: 16),
                _buildLegend(color: cs.error, text: 'Negativos', value: widget.negativeCount),
              ],
            ),
          )
        ],
      ),
    );
  }

  PieChartSectionData _buildSection({
    required bool isTouched,
    required double value,
    required Color color,
    required Color onColor,
    required int total,
  }) {
    final fontSize = isTouched ? 16.0 : 14.0;
    final radius = isTouched ? 60.0 : 50.0;
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(0) : '0';

    return PieChartSectionData(
      color: color,
      value: value,
      title: '$percentage%',
      radius: radius,
      titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: onColor, shadows: const [Shadow(color: Colors.black26, blurRadius: 2)]),
    );
  }

  // Helper da legenda corrigido para ser flexível
  Widget _buildLegend({
    required Color color,
    required String text,
    required int value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: color,
          ),
          margin: const EdgeInsets.only(top: 4), // Alinha o quadrado com o texto
        ),
        const SizedBox(width: 8),
        // O `Expanded` permite que o texto quebre a linha se não houver espaço
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium, // Estilo padrão
              children: <TextSpan>[
                TextSpan(text: '$text '),
                TextSpan(
                  text: '($value)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
