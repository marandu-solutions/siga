// lib/Pages/FeedbacksPage/feedbacks_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../Model/pedidos_model.dart';
import '../../Model/pedidos.dart';

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
            Icon(icon, size: 36, color: cs.onPrimaryContainer),
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Integração com CRUD de pedidos
    final pedidos = context.watch<PedidoModel>().pedidos;
    final allFeedbacks = <Map<String, dynamic>>[];
    for (var p in pedidos) {
      for (var f in p.feedbacks) {
        allFeedbacks.add({
          'pedidoId': p.id,
          'numero': p.telefoneCliente,
          'nome': p.nomeCliente,
          'mensagem': f.mensagem,
          'positive': f.positive,
          'data': f.data,
        });
      }
    }
    final posCount = allFeedbacks.where((f) => f['positive'] == true).length;
    final negCount = allFeedbacks.length - posCount;

    final satisfactionData = [for (int i = 0; i < 7; i++) (80 + i).toDouble()];

    final filtered = allFeedbacks.where((f) {
      if (filter == 'all') return true;
      return filter == 'positive' ? f['positive'] == true : f['positive'] == false;
    }).toList();

    final uniqueCustomers = <String>{};
    for (var p in pedidos) uniqueCustomers.add(p.nomeCliente);

    final ordersProcessed = pedidos.length;
    final customersServed = uniqueCustomers.length;

    final totalFeedbacks = allFeedbacks.length;
    final satisfactionRate = totalFeedbacks > 0
        ? ((posCount / totalFeedbacks * 100).toStringAsFixed(0) + '%')
        : '0%';

// Average response time: difference between feedback and order date, in minutes
    int totalMinutes = 0;
    int countResponse = 0;
    for (var f in allFeedbacks) {
      final pid = f['pedidoId'] as int;
      final pedido = pedidos.firstWhere((p) => p.id == pid);
      final diff = (f['data'] as DateTime).difference(pedido.dataPedido).inMinutes;
      totalMinutes += diff;
      countResponse++;
    }
    final avgMinutes = countResponse > 0 ? (totalMinutes ~/ countResponse) : 0;
    final avgResponse = '${avgMinutes}m';

// Cost savings: sum of valorTotal for pedidos with positive feedback
    final positivePedidoIds = <int>{};
    for (var f in allFeedbacks) {
      if (f['positive'] == true) positivePedidoIds.add(f['pedidoId'] as int);
    }
    double costSavings = 0;
    for (var pid in positivePedidoIds) {
      final p = pedidos.firstWhere((p) => p.id == pid);
      costSavings += p.valorTotal;
    }
    final costSavingsLabel = '\$${costSavings.toStringAsFixed(2)}';

    final metrics = [
      {'icon': Icons.people, 'number': '\$customersServed', 'label': 'Clientes Atendidos'},
      {'icon': Icons.shopping_cart, 'number': '\$ordersProcessed', 'label': 'Pedidos Processados'},
      {'icon': Icons.sentiment_satisfied, 'number': satisfactionRate, 'label': 'Taxa de Satisfação'},
      {'icon': Icons.timer, 'number': avgResponse, 'label': 'Tempo Médio de Resposta'},
      {'icon': Icons.attach_money, 'number': costSavingsLabel, 'label': 'Economia Gerada'},
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, pedidos),
        child: const Icon(Icons.add_comment),
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        child: isMobile
            ? _buildMobile(
            cs, metrics, satisfactionData, posCount, negCount, filtered)
            : _buildDesktop(
            cs, metrics, satisfactionData, posCount, negCount, filtered),
      ),
    );
  }

  void _showAddDialog(BuildContext context, List<Pedido> pedidos) {
    final _selectedPedido = ValueNotifier<Pedido?>(null);
    final _messageController = TextEditingController();
    final _positive = ValueNotifier<bool>(true);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<Pedido?>(
                valueListenable: _selectedPedido,
                builder: (_, sel, __) => DropdownButton<Pedido>(
                  hint: const Text('Selecione Pedido'),
                  isExpanded: true,
                  value: sel,
                  items: pedidos
                      .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('#${p.numeroPedido} - ${p.nomeCliente}'),
                  ))
                      .toList(),
                  onChanged: (v) => _selectedPedido.value = v,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _positive,
                builder: (_, pos, __) => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Positivo'),
                        value: true,
                        groupValue: pos,
                        onChanged: (v) => _positive.value = v!,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Negativo'),
                        value: false,
                        groupValue: pos,
                        onChanged: (v) => _positive.value = v!,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final pedido = _selectedPedido.value;
              final msg = _messageController.text.trim();
              if (pedido != null && msg.isNotEmpty) {
                final feedback = FeedbackEntry(
                  id: UniqueKey().toString(),
                  mensagem: msg,
                  positive: _positive.value,
                  data: DateTime.now(),
                );
                context.read<PedidoModel>().adicionarFeedback(pedido.id, feedback);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(
      ColorScheme cs,
      List<Map<String, dynamic>> metrics,
      List<double> satisfactionData,
      int posCount,
      int negCount,
      List<Map<String, dynamic>> feedbacks,
      ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Indicadores',
              style: TextStyle(
                  color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: metrics
                .map((m) => MetricCard(
                icon: m['icon'], number: m['number'], label: m['label']))
                .toList(),
          ),
          const SizedBox(height: 20),
          Card(
            color: cs.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Satisfação ao longo do tempo',
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Distribuição de Sentimento',
                      style: TextStyle(color: cs.onPrimaryContainer)),
                  const SizedBox(height: 8),
                  SentimentPieChart(
                      positiveCount: posCount, negativeCount: negCount),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFilterToggle(cs),
          const SizedBox(height: 12),
          ..._buildFeedbackItems(feedbacks, cs),
        ],
      ),
    );
  }

  Widget _buildDesktop(
      ColorScheme cs,
      List<Map<String, dynamic>> metrics,
      List<double> satisfactionData,
      int posCount,
      int negCount,
      List<Map<String, dynamic>> feedbacks,
      ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Text('Feedbacks dos Clientes',
              style: TextStyle(
                  color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Text('Indicadores',
              style: TextStyle(
                  color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: metrics
                .map((m) => MetricCard(
                icon: m['icon'], number: m['number'], label: m['label']))
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
                        Text('Satisfação ao longo do tempo',
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
                        Text('Distribuição de Sentimento',
                            style: TextStyle(color: cs.onPrimaryContainer)),
                        const SizedBox(height: 10),
                        SentimentPieChart(
                            positiveCount: posCount, negativeCount: negCount),
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
              final f = feedbacks[idx];
              return Card(
                color: cs.surfaceVariant,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            f['positive'] ? Icons.thumb_up : Icons.thumb_down,
                            color: f['positive'] ? cs.secondary : cs.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(f['nome'],
                                style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text('${f['data'].day}/${f['data'].month}/${f['data'].year}',
                              style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(f['mensagem'], style: TextStyle(color: cs.onSurface)),
                    ],
                  ),
                ),
              );
            },
            childCount: feedbacks.length,
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
        filter = i == 0 ? 'all' : i == 1 ? 'positive' : 'negative';
      }),
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('All')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Positive')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Negative')),
      ],
    );
  }

  List<Widget> _buildFeedbackItems(List<Map<String, dynamic>> list, ColorScheme cs) {
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
                f['positive'] ? Icons.thumb_up : Icons.thumb_down,
                color: f['positive'] ? cs.secondary : cs.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(f['nome'],
                    style: TextStyle(
                        color: cs.onSurface, fontWeight: FontWeight.w600)),
              ),
              Text(
                '${f['data'].day}/${f['data'].month}/${f['data'].year}',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ]),
            const SizedBox(height: 8),
            Text(f['mensagem'], style: TextStyle(color: cs.onSurface)),
          ],
        ),
      ),
    ))
        .toList();
  }
}