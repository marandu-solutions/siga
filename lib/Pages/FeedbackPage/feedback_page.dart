import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const MetricCard({Key? key, required this.icon, required this.number, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Container(
        width: 140,
        // Removido height fixo para permitir expansão quando o texto for maior
        decoration: BoxDecoration(
          color: const Color(0xFF262649),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.deepPurpleAccent),
            const SizedBox(height: 8),
            Text(
              number,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
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
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text(
                  'D${v.toInt() + 1}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: false),
              color: primary,
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
  final Color positiveColor;
  final Color negativeColor;

  const SentimentPieChart({
    Key? key,
    required this.positiveCount,
    required this.negativeCount,
    required this.positiveColor,
    required this.negativeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = positiveCount + negativeCount;
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 32,
          sectionsSpace: 2,
          sections: [
            PieChartSectionData(
              value: positiveCount.toDouble(),
              color: positiveColor,
              radius: 48,
              title: total > 0 ? '${(positiveCount / total * 100).toStringAsFixed(0)}%' : '0%',
              titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: negativeCount.toDouble(),
              color: negativeColor,
              radius: 48,
              title: total > 0 ? '${(negativeCount / total * 100).toStringAsFixed(0)}%' : '0%',
              titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
    final small = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Padding(
        padding: EdgeInsets.all(small ? 12 : 24),
        child: small ? _buildMobile() : _buildDesktop(),
      ),
    );
  }

  Widget _buildMobile() {
    final posCount = feedbacks.where((f) => f['sentiment'] == 'positive').length;
    final negCount = feedbacks.length - posCount;
    final filtered = feedbacks.where((f) {
      if (filter == 'all') return true;
      return f['sentiment'] == filter;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Performance Indicators',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: metrics
                .map((m) => MetricCard(icon: m['icon'], number: m['number'], label: m['label']))
                .toList(),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFF262649),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Satisfaction Over Time', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  SatisfactionChart(data: satisfactionData),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFF262649),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Feedback Sentiment Distribution', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  SentimentPieChart(
                    positiveCount: posCount,
                    negativeCount: negCount,
                    positiveColor: Theme.of(context).colorScheme.primary,
                    negativeColor: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFilterToggle(),
          const SizedBox(height: 12),
          ..._buildFeedbackItems(),
        ],
      ),
    );
  }

  Widget _buildDesktop() {
    final theme = Theme.of(context);
    final posCount = feedbacks.where((f) => f['sentiment'] == 'positive').length;
    final negCount = feedbacks.length - posCount;
    final filtered = feedbacks.where((f) {
      if (filter == 'all') return true;
      return f['sentiment'] == filter;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Text(
            'Feedbacks dos Clientes',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: const Text('Key Performance Indicators', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: metrics
                .map((m) => MetricCard(icon: m['icon'], number: m['number'], label: m['label']))
                .toList(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Card(
            color: const Color(0xFF262649),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Satisfaction Over Time', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  SatisfactionChart(data: satisfactionData),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Card(
            color: const Color(0xFF262649),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Feedback Sentiment Distribution', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  SentimentPieChart(
                    positiveCount: posCount,
                    negativeCount: negCount,
                    positiveColor: theme.colorScheme.primary,
                    negativeColor: theme.colorScheme.error,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _buildFilterToggle()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, idx) {
              final f = filtered[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF262649),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          f['sentiment'] == 'positive' ? Icons.thumb_up : Icons.thumb_down,
                          color: f['sentiment'] == 'positive' ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f['nome']!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                        Text(
                          f['numero']!,
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      f['mensagem']!,
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              );
            },
            childCount: filtered.length,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterToggle() {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      fillColor: Colors.deepPurpleAccent,
      selectedColor: Colors.white,
      color: Colors.white70,
      isSelected: isSelected,
      onPressed: (i) => setState(() {
        for (int j = 0; j < isSelected.length; j++) isSelected[j] = j == i;
        filter = i == 0 ? 'all' : (i == 1 ? 'positive' : 'negative');
      }),
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('All')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Positive')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Negative')),
      ],
    );
  }

  List<Widget> _buildFeedbackItems() {
    final list = feedbacks.where((f) => filter == 'all' || f['sentiment'] == filter).toList();
    return list.map((f) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF262649),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  f['sentiment'] == 'positive' ? Icons.thumb_up : Icons.thumb_down,
                  color: f['sentiment'] == 'positive' ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    f['nome']!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                Text(
                  f['numero']!,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              f['mensagem']!,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      );
    }).toList();
  }
}