import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/pedidos.dart';
import 'Components/grafico_pizza.dart';
import 'Components/satisfacao_grafico.dart';
import 'components/metric_card.dart';

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

    // Carrega os pedidos e extrai todos os feedbacks
    final pedidos = context.watch<PedidoModel>().pedidos;
    final allFeedbacks = <Map<String, dynamic>>[];
    for (var p in pedidos) {
      for (var f in p.feedbacks) {
        allFeedbacks.add({
          'pedidoId': p.id,
          'nome': p.nomeCliente,
          'mensagem': f.mensagem,
          'positive': f.positive,
          'data': f.data,
        });
      }
    }

    // Contagens e métricas
    final posCount = allFeedbacks.where((f) => f['positive'] == true).length;
    final negCount = allFeedbacks.length - posCount;
    final totalFeedbacks = allFeedbacks.length;
    final satisfactionRate = totalFeedbacks > 0
        ? '${(posCount / totalFeedbacks * 100).toStringAsFixed(0)}%'
        : '0%';

    // Response time médio em minutos
    int totalMinutes = 0;
    for (var f in allFeedbacks) {
      final pedido = pedidos.firstWhere((p) => p.id == f['pedidoId'] as String);
      totalMinutes +=
          (f['data'] as DateTime).difference(pedido.dataPedido).inMinutes;
    }
    final avgResponse = totalFeedbacks > 0
        ? '${(totalMinutes ~/ totalFeedbacks)}m'
        : '0m';

    // Economia: soma de valorTotal de pedidos com feedback positivo
    final positiveIds = allFeedbacks
        .where((f) => f['positive'] == true)
        .map((f) => f['pedidoId'] as String)
        .toSet();
    double costSavings = 0;
    for (var id in positiveIds) {
      final p = pedidos.firstWhere((p) => p.id == id);
      costSavings += p.itens.fold(
          0.0, (sum, item) => sum + item.preco * item.quantidade);
    }
    final costSavingsLabel = '\$${costSavings.toStringAsFixed(2)}';

    // Clientes servidos e pedidos processados
    final customersServed =
    pedidos.map((p) => p.nomeCliente).toSet().length.toString();
    final ordersProcessed = pedidos.length.toString();

    // Lista de métricas para o MetricCard
    final metrics = [
      {
        'icon': Icons.people,
        'number': customersServed,
        'label': 'Clientes Atendidos'
      },
      {
        'icon': Icons.shopping_cart,
        'number': ordersProcessed,
        'label': 'Pedidos Processados'
      },
      {
        'icon': Icons.sentiment_satisfied,
        'number': satisfactionRate,
        'label': 'Taxa de Satisfação'
      },
      {'icon': Icons.timer, 'number': avgResponse, 'label': 'Tempo de Resposta'},
      {
        'icon': Icons.attach_money,
        'number': costSavingsLabel,
        'label': 'Economia Gerada'
      },
    ];

    // Dados de satisfação ao longo de 7 dias (exemplo)
    final satisfactionData =
    List.generate(7, (i) => 80 + i.toDouble());

    // Filtrar feedbacks
    final filtered = allFeedbacks.where((f) {
      if (filter == 'all') return true;
      return filter == 'positive'
          ? f['positive'] == true
          : f['positive'] == false;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Feedbacks dos Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, pedidos),
        child: const Icon(Icons.add_comment),
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        child: isMobile
            ? _buildMobile(cs, metrics, satisfactionData, posCount, negCount,
            filtered)
            : _buildDesktop(cs, metrics, satisfactionData, posCount,
            negCount, filtered),
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: metrics.map((m) {
              return MetricCard(
                icon: m['icon'] as IconData,
                number: m['number'] as String,
                label: m['label'] as String,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Satisfação ao longo do tempo',
                      style: TextStyle(color: cs.onSurface)),
                  const SizedBox(height: 8),
                  SatisfactionChart(data: satisfactionData),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Distribuição de Sentimento',
                      style: TextStyle(color: cs.onSurface)),
                  const SizedBox(height: 8),
                  SentimentPieChart(
                    positiveCount: posCount,
                    negativeCount: negCount,
                  ),
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
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 24),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: metrics.map((m) {
                return MetricCard(
                  icon: m['icon'] as IconData,
                  number: m['number'] as String,
                  label: m['label'] as String,
                );
              }).toList(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SatisfactionChart(data: satisfactionData),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SentimentPieChart(
                      positiveCount: posCount,
                      negativeCount: negCount,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: _buildFilterToggle(cs)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, idx) {
              final f = feedbacks[idx];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            f['positive'] ? Icons.thumb_up : Icons.thumb_down,
                            color: f['positive']
                                ? cs.secondary
                                : cs.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(f['nome'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))),
                          Text(
                            '${f['data'].day}/${f['data'].month}/${f['data'].year}',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(f['mensagem']),
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
      onPressed: (i) {
        setState(() {
          for (var j = 0; j < isSelected.length; j++) {
            isSelected[j] = j == i;
          }
          filter = i == 0 ? 'all' : i == 1 ? 'positive' : 'negative';
        });
      },
      children: const [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 12), child: Text('All')),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Positive')),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Negative')),
      ],
    );
  }

  List<Widget> _buildFeedbackItems(
      List<Map<String, dynamic>> list, ColorScheme cs) {
    return list
        .map((f) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
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
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(
                '${f['data'].day}/${f['data'].month}/${f['data'].year}',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ]),
            const SizedBox(height: 8),
            Text(f['mensagem']),
          ],
        ),
      ),
    ))
        .toList();
  }

  void _showAddDialog(BuildContext context, List<Pedido> pedidos) {
    final selected = ValueNotifier<Pedido?>(null);
    final controller = TextEditingController();
    final positive = ValueNotifier<bool>(true);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<Pedido?>(
              valueListenable: selected,
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
                onChanged: (v) => selected.value = v,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: positive,
              builder: (_, pos, __) => Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Positivo'),
                      value: true,
                      groupValue: pos,
                      onChanged: (v) => positive.value = v!,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Negativo'),
                      value: false,
                      groupValue: pos,
                      onChanged: (v) => positive.value = v!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                final pedido = selected.value;
                final msg = controller.text.trim();
                if (pedido != null && msg.isNotEmpty) {
                  final feedback = FeedbackEntry(
                    id: UniqueKey().toString(),
                    mensagem: msg,
                    positive: positive.value,
                    data: DateTime.now(),
                  );
                  context
                      .read<PedidoModel>()
                      .adicionarFeedback(pedido.id, feedback);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar')),
        ],
      ),
    );
  }
}
