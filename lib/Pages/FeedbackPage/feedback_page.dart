import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  MetricCard({required this.icon, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(seconds: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Color(0xFF262649),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepPurpleAccent),
            SizedBox(height: 10),
            Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SatisfactionChart extends StatelessWidget {
  final List<double> data;

  SatisfactionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'Dia ${value.toInt() + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
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
              color: theme.colorScheme.primary,
              barWidth: 4,
              dotData: FlDotData(show: false),
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

  SentimentPieChart({
    required this.positiveCount,
    required this.negativeCount,
    required this.positiveColor,
    required this.negativeColor,
  });

  @override
  Widget build(BuildContext context) {
    final total = positiveCount + negativeCount;
    return Container(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: positiveCount.toDouble(),
              color: positiveColor,
              title: total > 0 ? '${(positiveCount / total * 100).toStringAsFixed(1)}%' : '0%',
              radius: 50,
              titleStyle: TextStyle(color: Colors.white, fontSize: 14),
            ),
            PieChartSectionData(
              value: negativeCount.toDouble(),
              color: negativeColor,
              title: total > 0 ? '${(negativeCount / total * 100).toStringAsFixed(1)}%' : '0%',
              radius: 50,
              titleStyle: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
          sectionsSpace: 0,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}

class FeedbacksPage extends StatefulWidget {
  @override
  _FeedbacksPageState createState() => _FeedbacksPageState();
}

class _FeedbacksPageState extends State<FeedbacksPage> {
  List<bool> isSelected = [true, false, false]; // all, positive, negative
  String filter = 'all';

  List<Map<String, dynamic>> metrics = [
    {'icon': Icons.people, 'number': '1500', 'label': 'Customers Served'},
    {'icon': Icons.shopping_cart, 'number': '2000', 'label': 'Orders Processed'},
    {'icon': Icons.sentiment_satisfied, 'number': '85%', 'label': 'Satisfaction Rate'},
    {'icon': Icons.timer, 'number': '30s', 'label': 'Avg Response Time'},
    {'icon': Icons.attach_money, 'number': '\$5000', 'label': 'Cost Savings'},
  ];

  List<double> satisfactionData = [80, 82, 85, 87, 85, 88];

  List<Map<String, String>> feedbacks = [
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
    final theme = Theme.of(context);

    List<Map<String, String>> filteredFeedbacks = feedbacks.where((f) {
      if (filter == 'all') return true;
      return f['sentiment'] == filter;
    }).toList();

    int positiveCount = feedbacks.where((f) => f['sentiment'] == 'positive').length;
    int negativeCount = feedbacks.where((f) => f['sentiment'] == 'negative').length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Text(
                "Feedbacks dos Clientes",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            SliverToBoxAdapter(
              child: Text(
                "Key Performance Indicators",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: metrics.map((metric) => MetricCard(
                  icon: metric['icon'],
                  number: metric['number'],
                  label: metric['label'],
                )).toList(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            SliverToBoxAdapter(
              child: Card(
                color: Color(0xFF262649),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer Satisfaction Over Time", style: TextStyle(color: Colors.white, fontSize: 18)),
                      SizedBox(height: 10),
                      SatisfactionChart(data: satisfactionData),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            SliverToBoxAdapter(
              child: Card(
                color: Color(0xFF262649),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Feedback Sentiment Distribution", style: TextStyle(color: Colors.white, fontSize: 18)),
                      SizedBox(height: 10),
                      SentimentPieChart(
                        positiveCount: positiveCount,
                        negativeCount: negativeCount,
                        positiveColor: theme.colorScheme.primary,
                        negativeColor: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            SliverToBoxAdapter(
              child: ToggleButtons(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('All'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Positive'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Negative'),
                  ),
                ],
                isSelected: isSelected,
                onPressed: (index) {
                  setState(() {
                    for (int i = 0; i < isSelected.length; i++) {
                      isSelected[i] = i == index;
                    }
                    if (index == 0) filter = 'all';
                    else if (index == 1) filter = 'positive';
                    else filter = 'negative';
                  });
                },
                color: Colors.white,
                selectedColor: Colors.white,
                fillColor: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final feedback = filteredFeedbacks[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
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
                              feedback['sentiment'] == 'positive' ? Icons.thumb_up : Icons.thumb_down,
                              color: feedback['sentiment'] == 'positive' ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feedback['nome'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              feedback['numero'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feedback['mensagem'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: filteredFeedbacks.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}