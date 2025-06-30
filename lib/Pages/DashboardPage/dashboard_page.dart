import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import 'Components/metric_card.dart';
import 'Components/perfomance_line_chart.dart';


enum PeriodoFiltro { hoje, semana, mes }

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
      // No app real, você chamaria a lógica para recarregar os dados
      // com base no novo período selecionado.
    }
  }

  // Função de placeholder para navegação.
  // No app real, isso usaria o seu sistema de navegação (Ex: Provider, GoRouter).
  void _navigateToPage(String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando para a página de $pageName...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Um ponto de quebra mais adequado para layouts de 2 colunas.
    final isDesktop = MediaQuery.of(context).size.width > 1100;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      // Usar um CustomScrollView permite misturar widgets normais e listas
      // de forma mais eficiente e performática.
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Painel de Controle"),
            pinned: true,
            backgroundColor: theme.colorScheme.background.withOpacity(0.8),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
              // O corpo do dashboard se adapta ao tamanho da tela.
              child: isDesktop
                  ? _buildDesktopBody()
                  : _buildMobileBody(),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO PRINCIPAIS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
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
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna principal com gráficos e lista de ações
        Expanded(
          flex: 3,
          child: Column(
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
        // Coluna lateral com atividade recente
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
    // Agora os cards são interativos
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        MetricCard(icon: LucideIcons.dollarSign, number: 'R\$ 1.250,75', label: 'Vendas', onTap: () => _navigateToPage('Relatórios')),
        MetricCard(icon: LucideIcons.trendingUp, number: 'R\$ 480,30', label: 'Lucro Est.', onTap: () => _navigateToPage('Relatórios')),
        MetricCard(icon: LucideIcons.receipt, number: '42', label: 'Pedidos', onTap: () => _navigateToPage('Pedidos')),
        MetricCard(icon: LucideIcons.users, number: '8', label: 'Novos Clientes', onTap: () => _navigateToPage('Clientes')),
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
