import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/pedidos.dart';
import 'Components/grafico_pizza.dart';
import 'Components/satisfacao_grafico.dart';
import 'components/metric_card.dart';
import 'package:intl/intl.dart';

class FeedbacksPage extends StatefulWidget {
  const FeedbacksPage({Key? key}) : super(key: key);

  @override
  _FeedbacksPageState createState() => _FeedbacksPageState();
}

class _FeedbacksPageState extends State<FeedbacksPage> {
  String _filter = 'all';

  // SUA FUNÇÃO ORIGINAL PARA ADICIONAR FEEDBACK, AGORA REINTEGRADA
  void _showAddDialog(BuildContext context, List<Pedido> pedidos) {
    final selected = ValueNotifier<Pedido?>(null);
    final controller = TextEditingController();
    final positive = ValueNotifier<bool>(true);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<Pedido?>(
                valueListenable: selected,
                builder: (_, sel, __) => DropdownButtonFormField<Pedido>(
                  hint: const Text('Selecione um Pedido'),
                  isExpanded: true,
                  value: sel,
                  items: pedidos.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('#${p.id.substring(0,6)} - ${p.nomeCliente}', overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => selected.value = v,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Mensagem', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: positive,
                builder: (_, pos, __) => Row(
                  children: [
                    Expanded(child: RadioListTile<bool>(title: const Text('Positivo'), value: true, groupValue: pos, onChanged: (v) => positive.value = v!)),
                    Expanded(child: RadioListTile<bool>(title: const Text('Negativo'), value: false, groupValue: pos, onChanged: (v) => positive.value = v!)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // CORREÇÃO: O ponto de quebra foi aumentado para 950.
    final isMobile = MediaQuery.of(context).size.width < 950;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Feedbacks'),
      ),
      // BOTÃO DE ADICIONAR AGORA ESTÁ AQUI
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, context.read<PedidoModel>().pedidos),
        tooltip: 'Adicionar Feedback',
        child: const Icon(Icons.add_comment_outlined),
      ),
      body: Consumer<PedidoModel>(
        builder: (context, pedidoModel, child) {
          final allFeedbacks = <Map<String, dynamic>>[];
          for (var p in pedidoModel.pedidos) {
            for (var f in p.feedbacks) {
              allFeedbacks.add({
                'pedidoId': p.id, 'nome': p.nomeCliente,
                'mensagem': f.mensagem, 'positive': f.positive, 'data': f.data,
              });
            }
          }

          final posCount = allFeedbacks.where((f) => f['positive'] == true).length;
          final negCount = allFeedbacks.length - posCount;
          final totalFeedbacks = allFeedbacks.length;
          final satisfactionRate = totalFeedbacks > 0 ? (posCount / totalFeedbacks * 100) : 0.0;
          final satisfactionData = List.generate(7, (i) => 80.0 + i - (i * 2.5));

          final filteredFeedbacks = allFeedbacks.where((f) {
            if (_filter == 'all') return true;
            return _filter == 'positive' ? f['positive'] == true : f['positive'] == false;
          }).toList();

          final metrics = [
            {'icon': Icons.reviews_outlined, 'number': '$totalFeedbacks', 'label': 'Total de Feedbacks'},
            {'icon': Icons.sentiment_satisfied_outlined, 'number': '${satisfactionRate.toStringAsFixed(0)}%', 'label': 'Satisfação', 'color': theme.colorScheme.primaryContainer},
            {'icon': Icons.thumb_up_alt_outlined, 'number': '$posCount', 'label': 'Positivos', 'color': theme.colorScheme.secondaryContainer},
            {'icon': Icons.thumb_down_alt_outlined, 'number': '$negCount', 'label': 'Negativos', 'color': theme.colorScheme.errorContainer},
          ];

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
            children: [
              // LÓGICA DO IndicadoresSection AGORA ESTÁ DIRETAMENTE AQUI
              Text('Desempenho Geral', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: metrics.map((m) => SizedBox(
                  width: 150,
                  child: MetricCard(
                    icon: m['icon'] as IconData,
                    number: m['number'] as String,
                    label: m['label'] as String,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              _buildChartsSection(context, satisfactionData, posCount, negCount),
              const SizedBox(height: 24),
              _buildFeedbackListSection(context, filteredFeedbacks),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, List<double> satisfactionData, int posCount, int negCount) {
    // CORREÇÃO: O ponto de quebra foi aumentado para 950.
    final isMobile = MediaQuery.of(context).size.width < 950;

    final satisfactionChartCard = Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Satisfação ao Longo do Tempo', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 16), SatisfactionChart(data: satisfactionData)])));
    final sentimentPieChartCard = Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Distribuição de Sentimento', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 16), SentimentPieChart(positiveCount: posCount, negativeCount: negCount)])));

    if (isMobile) {
      return Column(children: [satisfactionChartCard, const SizedBox(height: 16), sentimentPieChartCard]);
    } else {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: satisfactionChartCard), const SizedBox(width: 24), Expanded(flex: 2, child: sentimentPieChartCard)]);
    }
  }

  Widget _buildFeedbackListSection(BuildContext context, List<Map<String, dynamic>> feedbacks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CORREÇÃO: Usando Wrap para quebrar a linha em telas menores.
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Feedbacks Recentes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            _buildFilterToggle(context),
          ],
        ),
        const SizedBox(height: 16),
        if (feedbacks.isEmpty) const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Text('Nenhum feedback encontrado para este filtro.')))
        else ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbacks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) => _FeedbackCard(feedback: feedbacks[index]),
        ),
      ],
    );
  }

  Widget _buildFilterToggle(BuildContext context) {
    // CORREÇÃO: Estilo customizado para remover o fundo do item selecionado.
    return SegmentedButton<String>(
      showSelectedIcon: false, // Remove o ícone de "check" padrão.
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            // Usa uma cor primária sutil para o fundo quando selecionado.
            if (states.contains(MaterialState.selected)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.15);
            }
            // Retorna nulo para usar o fundo padrão (transparente).
            return null;
          },
        ),
      ),
      segments: const <ButtonSegment<String>>[
        ButtonSegment(value: 'all', label: Text('Todos'), icon: Icon(Icons.clear_all)),
        ButtonSegment(value: 'positive', label: Text('Positivos'), icon: Icon(Icons.thumb_up)),
        ButtonSegment(value: 'negative', label: Text('Negativos'), icon: Icon(Icons.thumb_down)),
      ],
      selected: {_filter},
      onSelectionChanged: (newSelection) => setState(() => _filter = newSelection.first),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool isPositive = feedback['positive'];
    final iconColor = isPositive ? cs.secondary : cs.error;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: iconColor.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isPositive ? Icons.thumb_up_alt_rounded : Icons.thumb_down_alt_rounded, color: iconColor),
                const SizedBox(width: 12),
                Expanded(child: Text(feedback['nome'], style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                Text(DateFormat('dd/MM/yy').format(feedback['data']), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
            const Divider(height: 24),
            Text(feedback['mensagem'], style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
