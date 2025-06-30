import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:siga/Model/feedbackmodel.dart';
import 'package:siga/Model/pedidos.dart';
import 'package:siga/Service/auth_service.dart';
import 'package:siga/Service/feedback_service.dart';
import 'package:siga/Service/pedidos_service.dart';


// Os componentes de UI que você criou podem ser importados normalmente.
import 'Components/metric_card.dart';
import 'Components/grafico_pizza.dart';
import 'Components/satisfacao_grafico.dart';

class FeedbacksPage extends StatefulWidget {
  const FeedbacksPage({super.key});

  @override
  _FeedbacksPageState createState() => _FeedbacksPageState();
}

class _FeedbacksPageState extends State<FeedbacksPage> {
  // O estado do filtro permanece local à UI, o que está correto.
  String _filter = 'all';

  // --- MÉTODO _showAddDialog TOTALMENTE REFEITO ---
  void _showAddDialog(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final selectedPedido = ValueNotifier<Pedido?>(null);
    final controller = TextEditingController();
    final isPositive = ValueNotifier<bool>(true);

    // Acessamos os serviços necessários para a lógica do diálogo
    final feedbackService = context.read<FeedbackService>();
    final pedidoService = context.read<PedidoService>();
    final authService = context.read<AuthService>();
    final empresaId = authService.empresaAtual?.id;

    if (empresaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Não foi possível identificar a empresa.')));
        return;
    }

    final inputDecoration = InputDecoration(
      filled: true,
      // Usando uma cor do tema que contrasta com o fundo do diálogo
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Feedback'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<List<Pedido>>(
                future: pedidoService.getPedidosDaEmpresaStream(empresaId).first,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Nenhum pedido para adicionar feedback.");
                  }
                  final pedidos = snapshot.data ?? [];
                  return ValueListenableBuilder<Pedido?>(
                    valueListenable: selectedPedido,
                    builder: (_, sel, __) => DropdownButtonFormField<Pedido>(
                      hint: const Text('Selecione um Pedido'),
                      isExpanded: true,
                      value: sel,
                      // Estilo para o texto do item selecionado e do menu
                      style: TextStyle(color: cs.onSurface),
                      decoration: inputDecoration.copyWith(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                      ),
                      dropdownColor: cs.surfaceContainerHighest, // Cor do fundo do menu
                      items: pedidos.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('#${p.numeroPedido} - ${p.cliente['nome']}', overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (v) => selectedPedido.value = v,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: TextStyle(color: cs.onSurface), // Cor do texto digitado
                decoration: inputDecoration.copyWith(labelText: 'Mensagem'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: isPositive,
                builder: (_, pos, __) => Row(
                  children: [
                    Expanded(child: RadioListTile<bool>(title: const Text('Positivo'), value: true, groupValue: pos, onChanged: (v) => isPositive.value = v!)),
                    Expanded(child: RadioListTile<bool>(title: const Text('Negativo'), value: false, groupValue: pos, onChanged: (v) => isPositive.value = v!)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final pedido = selectedPedido.value;
              final msg = controller.text.trim();
              if (pedido != null && msg.isNotEmpty) {
                final feedback = FeedbackModel(
                  id: '',
                  pedidoId: pedido.id,
                  empresaId: empresaId,
                  mensagem: msg,
                  positivo: isPositive.value,
                  data: Timestamp.now(),
                  nomeCliente: pedido.cliente['nome'] ?? 'Cliente',
                );

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                try {
                  await feedbackService.adicionarFeedback(pedido.id, feedback);
                  scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Feedback adicionado com sucesso!')));
                  navigator.pop();
                } catch (e) {
                  scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao adicionar feedback: $e')));
                }
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
    final isMobile = MediaQuery.of(context).size.width < 1450;
    
    final authService = context.watch<AuthService>();
    final feedbackService = context.read<FeedbackService>();
    final empresaId = authService.empresaAtual?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Feedbacks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Adicionar Feedback',
        child: const Icon(Icons.add_comment_outlined),
      ),
      body: empresaId == null
          ? const Center(child: Text("Carregando dados da empresa..."))
          : StreamBuilder<List<FeedbackModel>>(
              stream: feedbackService.getFeedbacksDaEmpresaStream(empresaId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Captura o erro do índice e mostra a mensagem
                  print("====== ERRO STREAM FEEDBACKS: ${snapshot.error}");
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Erro ao carregar feedbacks. Verifique se o índice do Firestore foi criado corretamente. Detalhes: ${snapshot.error}", textAlign: TextAlign.center),
                  ));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final allFeedbacks = snapshot.data ?? [];

                final posCount = allFeedbacks.where((f) => f.positivo).length;
                final negCount = allFeedbacks.length - posCount;
                final totalFeedbacks = allFeedbacks.length;
                final satisfactionRate = totalFeedbacks > 0 ? (posCount / totalFeedbacks * 100) : 0.0;
                final satisfactionData = List.generate(7, (i) => 80.0 + i - (i * 2.5));

                final filteredFeedbacks = allFeedbacks.where((f) {
                  if (_filter == 'all') return true;
                  return _filter == 'positive' ? f.positivo : !f.positivo;
                }).toList();

                final metrics = [
                  {'icon': LucideIcons.messageSquare, 'number': '$totalFeedbacks', 'label': 'Total de Feedbacks'},
                  {'icon': LucideIcons.smile, 'number': '${satisfactionRate.toStringAsFixed(0)}%', 'label': 'Satisfação', 'color': theme.colorScheme.primaryContainer},
                  {'icon': LucideIcons.thumbsUp, 'number': '$posCount', 'label': 'Positivos', 'color': theme.colorScheme.secondaryContainer},
                  {'icon': LucideIcons.thumbsDown, 'number': '$negCount', 'label': 'Negativos', 'color': theme.colorScheme.errorContainer},
                ];

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
                  children: [
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
                          color: m['color'] as Color?,
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
    final isMobile = MediaQuery.of(context).size.width < 1250;
    final satisfactionChartCard = Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Satisfação ao Longo do Tempo', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 16), SatisfactionChart(data: satisfactionData)])));
    final sentimentPieChartCard = Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Distribuição de Sentimento', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 16), SentimentPieChart(positiveCount: posCount, negativeCount: negCount)])));
    if (isMobile) {
      return Column(children: [satisfactionChartCard, const SizedBox(height: 16), sentimentPieChartCard]);
    } else {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: satisfactionChartCard), const SizedBox(width: 24), Expanded(flex: 2, child: sentimentPieChartCard)]);
    }
  }

  Widget _buildFeedbackListSection(BuildContext context, List<FeedbackModel> feedbacks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    return SegmentedButton<String>(
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.15);
            }
            return null;
          },
        ),
      ),
      segments: const <ButtonSegment<String>>[
        ButtonSegment(value: 'all', label: Text('Todos'), icon: Icon(LucideIcons.list)),
        ButtonSegment(value: 'positive', label: Text('Positivos'), icon: Icon(LucideIcons.thumbsUp)),
        ButtonSegment(value: 'negative', label: Text('Negativos'), icon: Icon(LucideIcons.thumbsDown)),
      ],
      selected: {_filter},
      onSelectionChanged: (newSelection) => setState(() => _filter = newSelection.first),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool isPositive = feedback.positivo;
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
                Icon(isPositive ? LucideIcons.thumbsUp : LucideIcons.thumbsDown, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(feedback.nomeCliente, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                Text(DateFormat('dd/MM/yy').format(feedback.data.toDate()), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
            const Divider(height: 24),
            Text(feedback.mensagem, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}