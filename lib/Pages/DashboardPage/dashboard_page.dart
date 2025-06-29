import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Importando os componentes que você já separou em outros arquivos
import 'Components/metric_card.dart';
import 'Components/perfomance_line_chart.dart';

// --- ENUM PARA O FILTRO DE PERÍODO ---
enum PeriodoFiltro { hoje, semana, mes, ano }

// ===================================================================
// =================== PÁGINA PRINCIPAL DO DASHBOARD =================
// ===================================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  PeriodoFiltro _selectedPeriod = PeriodoFiltro.mes;

  void _onPeriodChanged(Set<PeriodoFiltro> newSelection) {
    if (newSelection.isNotEmpty) {
      setState(() {
        _selectedPeriod = newSelection.first;
      });
    }
  }

  // A função de navegação agora está aqui apenas como exemplo futuro,
  // mas não é mais chamada pelos cards.
  void _navigateToPage(String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando para a página de $pageName...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 950;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDesktop),
            const SizedBox(height: 24),
            isDesktop ? _buildDesktopBody() : _buildMobileBody(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO PRINCIPAIS ---

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Painel de Controle",
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Visão geral do seu negócio em tempo real.",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        if (isDesktop)
          SegmentedButton<PeriodoFiltro>(
            selected: {_selectedPeriod},
            onSelectionChanged: _onPeriodChanged,
            segments: const [
              ButtonSegment(value: PeriodoFiltro.hoje, label: Text('Hoje')),
              ButtonSegment(value: PeriodoFiltro.semana, label: Text('Semana')),
              ButtonSegment(value: PeriodoFiltro.mes, label: Text('Mês')),
              ButtonSegment(value: PeriodoFiltro.ano, label: Text('Ano')),
            ],
          ),
      ],
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildMetricCards(),
              const SizedBox(height: 24),
              _buildPerformanceChartCard(),
              const SizedBox(height: 24),
              _buildOpenOrdersCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildRecentActivityCard(),
        ),
      ],
    );
  }

  Widget _buildMobileBody() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<PeriodoFiltro>(
            selected: {_selectedPeriod},
            onSelectionChanged: _onPeriodChanged,
            segments: const [
              ButtonSegment(value: PeriodoFiltro.hoje, label: Text('Hoje')),
              ButtonSegment(value: PeriodoFiltro.semana, label: Text('Semana')),
              ButtonSegment(value: PeriodoFiltro.mes, label: Text('Mês')),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildMetricCards(),
        const SizedBox(height: 24),
        _buildPerformanceChartCard(),
        const SizedBox(height: 24),
        _buildOpenOrdersCard(),
        const SizedBox(height: 24),
        _buildRecentActivityCard(),
      ],
    );
  }

  // --- WIDGETS DE SEÇÃO DO DASHBOARD ---

  Widget _buildMetricCards() {
    // CORREÇÃO: Removido o parâmetro `onTap` das chamadas do MetricCard.
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        MetricCard(icon: LucideIcons.dollarSign, number: 'R\$ 1.250,75', label: 'Vendas'),
        MetricCard(icon: LucideIcons.trendingUp, number: 'R\$ 480,30', label: 'Lucro Est.'),
        MetricCard(icon: LucideIcons.receipt, number: '42', label: 'Pedidos'),
        MetricCard(icon: LucideIcons.users, number: '8', label: 'Novos Clientes'),
      ],
    );
  }

  Widget _buildPerformanceChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Semanal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            PerformanceLineChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenOrdersCard() {
    final openOrders = [
      {'id': '#12345', 'cliente': 'Ana Silva', 'haQuantoTempo': '5 min atrás'},
      {'id': '#12344', 'cliente': 'Carlos Souza', 'haQuantoTempo': '12 min atrás'},
      {'id': '#12342', 'cliente': 'Mariana Lima', 'haQuantoTempo': '28 min atrás'},
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A Fazer Agora (Pedidos em Aberto)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...openOrders.map((order) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.receipt, color: Colors.amber),
              title: Text(order['cliente']!),
              subtitle: Text("Pedido ${order['id']}"),
              trailing: Text(order['haQuantoTempo']!),
              onTap: () => _navigateToPage("Detalhes do Pedido ${order['id']}"),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    final activities = [
      {'icon': LucideIcons.checkCircle, 'text': 'Pedido #12341 foi finalizado.', 'time': '2 min'},
      {'icon': LucideIcons.star, 'text': 'Novo feedback positivo recebido.', 'time': '15 min'},
      {'icon': LucideIcons.plusCircle, 'text': 'Novo pedido de Carla Dias.', 'time': '22 min'},
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Atividade Recente', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...activities.map((act) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(act['icon'] as IconData, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(act['text'] as String),
              trailing: Text(act['time'] as String, style: Theme.of(context).textTheme.bodySmall),
            )),
          ],
        ),
      ),
    );
  }
}
