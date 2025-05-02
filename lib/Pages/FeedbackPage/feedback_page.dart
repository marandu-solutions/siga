import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const MetricCard({
    Key? key,
    required this.icon,
    required this.number,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: cs.onPrimaryContainer), // Cor do ícone segue o tema
            const SizedBox(height: 8),
            Text(
              number,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cs.onPrimaryContainer.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class SatisfactionChart extends StatelessWidget {
  final List<double> data;
  const SatisfactionChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: cs.onSurface.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text(
                  'D${v.toInt() + 1}',
                  style: TextStyle(color: cs.onSurface, fontSize: 12),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}%',
                  style: TextStyle(color: cs.onSurface, fontSize: 12),
                ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: cs.onSurface.withOpacity(0.2)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: false),
              color: cs.primary,
            ),
          ],
        ),
      ),
    );
  }
}

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
                  fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: negativeCount.toDouble(),
              color: cs.error,
              radius: 48,
              title: total > 0
                  ? '${(negativeCount / total * 100).toStringAsFixed(0)}%'
                  : '0%',
              titleStyle: TextStyle(
                  color: cs.onError, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbacksPage extends StatefulWidget {
  const FeedbacksPage({Key? key}) : super(key: key);

  @override
  _FeedbacksPageState createState() => _FeedbacksPageState();
}

class _FeedbacksPageState extends State<FeedbacksPage> {
  List<bool> isSelected = [true, false, false];
  String filter = 'all';

  final List<Map<String, dynamic>> metrics = [
    {'icon': Icons.people, 'number': '1500', 'label': 'Customers Served'},
    {'icon': Icons.shopping_cart, 'number': '2000', 'label': 'Orders Processed'},
    {'icon': Icons.sentiment_satisfied, 'number': '85%', 'label': 'Satisfaction Rate'},
    {'icon': Icons.timer, 'number': '30s', 'label': 'Avg Response Time'},
    {'icon': Icons.attach_money, 'number': '\$5000', 'label': 'Cost Savings'},
  ];

  final List<double> satisfactionData = [80, 82, 85, 87, 85, 88];

  final List<Map<String, String>> feedbacks = [
    {
      'numero': '+55 84 91234-5678',
      'nome': 'João Silva',
      'mensagem': 'Excelente atendimento, muito rápido e eficiente!',
      'sentiment': 'positive'
    },
    {
      'numero': '+55 84 98765-4321',
      'nome': 'Maria Souza',
      'mensagem': 'Gostei muito das camisetas, só achei a entrega um pouco lenta.',
      'sentiment': 'negative'
    },
    {
      'numero': '+55 84 99876-1122',
      'nome': 'Carlos Lima',
      'mensagem': 'Serviço ótimo, voltarei a comprar com certeza!',
      'sentiment': 'positive'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        child: isMobile ? _buildMobile(cs) : _buildDesktop(cs),
      ),
    );
  }

Widget _buildMobile(ColorScheme cs) {
    final pos = feedbacks.where((f) => f['sentiment'] == 'positive').length;
    final neg = feedbacks.length - pos;
    final filtered =
    feedbacks.where((f) => filter == 'all' || f['sentiment'] == filter).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Key Performance Indicators',
              style: TextStyle(
                  color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: metrics
                .map((m) =>
                MetricCard(icon: m['icon'], number: m['number'], label: m['label']))
                .toList(),
          ),
          const SizedBox(height: 20),
          Card(
            color: cs.primaryContainer,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Satisfaction Over Time',
                      style: TextStyle(color: cs.onPrimaryContainer)),
                  const SizedBox(height: 8),
                  SatisfactionChart(data: satisfactionData),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: cs.primaryContainer,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Feedback Sentiment Distribution',
                      style: TextStyle(color: cs.onPrimaryContainer)),
                  const SizedBox(height: 8),
                  SentimentPieChart(positiveCount: pos, negativeCount: neg),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFilterToggle(cs),
          const SizedBox(height: 12),
          ..._buildFeedbackItems(filtered, cs),
        ],
      ),
    );
  }

  Widget _buildDesktop(ColorScheme cs) {
    final pos = feedbacks.where((f) => f['sentiment'] == 'positive').length;
    final neg = feedbacks.length - pos;
    final filtered =
    feedbacks.where((f) => filter == 'all' || f['sentiment'] == filter).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Text('Feedbacks dos Clientes',
              style: TextStyle(
                  color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Text('Key Performance Indicators',
              style: TextStyle(
                  color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: metrics
                .map((m) =>
                MetricCard(icon: m['icon'], number: m['number'], label: m['label']))
                .toList(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  color: cs.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer Satisfaction Over Time',
                            style: TextStyle(color: cs.onPrimaryContainer)),
                        const SizedBox(height: 10),
                        SatisfactionChart(data: satisfactionData),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: cs.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Feedback Sentiment Distribution',
                            style: TextStyle(color: cs.onPrimaryContainer)),
                        const SizedBox(height: 10),
                        SentimentPieChart(positiveCount: pos, negativeCount: neg),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _buildFilterToggle(cs)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, idx) {
              final f = filtered[idx];
              return Card(
                color: cs.surfaceVariant,
                margin: const EdgeInsets.only(bottom: 16),
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            f['sentiment'] == 'positive'
                                ? Icons.thumb_up
                                : Icons.thumb_down,
                            color: f['sentiment'] == 'positive'
                                ? cs.secondary
                                : cs.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(f['nome']!,
                                style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text(f['numero']!,
                              style:
                              TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(f['mensagem']!,
                          style: TextStyle(color: cs.onSurface)),
                    ],
                  ),
                ),
              );
            },
            childCount: filtered.length,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterToggle(ColorScheme cs) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      fillColor: cs.primary,
      selectedColor: cs.onPrimary,
      color: cs.onSurfaceVariant,
      isSelected: isSelected,
      onPressed: (i) => setState(() {
        for (var j = 0; j < isSelected.length; j++) {
          isSelected[j] = j == i;
        }
        filter = i == 0
            ? 'all'
            : i == 1
            ? 'positive'
            : 'negative';
      }),
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('All')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Positive')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Negative')),
      ],
    );
  }

  List<Widget> _buildFeedbackItems(List<Map<String, String>> list, ColorScheme cs) {
    return list
        .map((f) => Card(
      color: cs.surfaceVariant,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(
                f['sentiment'] == 'positive' ? Icons.thumb_up : Icons.thumb_down,
                color: f['sentiment'] == 'positive' ? cs.secondary : cs.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(f['nome']!,
                    style: TextStyle(
                        color: cs.onSurface, fontWeight: FontWeight.w600)),
              ),
              Text(f['numero']!, style: TextStyle(color: cs.onSurfaceVariant)),
            ]),
            const SizedBox(height: 8),
            Text(f['mensagem']!, style: TextStyle(color: cs.onSurface)),
          ],
        ),
      ),
    ))
        .toList();
  }
}
