import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../Model/pedidos.dart';
import 'Components/kanban.dart';
import 'Components/pedido_details_page.dart';
import 'Components/tabela.dart';
import '../../Themes/themes.dart'; // Adicionando o tema para uso

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  List<Pedido> pedidos = [
    Pedido(
      id: 1001,
      numeroPedido: "1001",
      nomeCliente: "João Silva",
      telefoneCliente: "84999999999",
      servico: "Camiseta Personalizada",
      quantidade: 10,
      tamanho: "M",
      tipoMalha: "Algodão",
      cor: "Azul",
      observacoes: "",
      valorTotal: 250.00,
      dataPedido: DateTime(2025, 4, 1, 12, 30),
      estado: EstadoPedido.emAberto,
    ),
    Pedido(
      id: 1002,
      numeroPedido: "1002",
      nomeCliente: "Maria Souza",
      telefoneCliente: "84988888888",
      servico: "Camiseta Básica",
      quantidade: 5,
      tamanho: "G",
      tipoMalha: "Poliéster",
      cor: "Branca",
      observacoes: "Entrega urgente",
      valorTotal: 150.00,
      dataPedido: DateTime(2025, 4, 2, 14, 10),
      estado: EstadoPedido.emAndamento,
    ),
  ];

  Map<EstadoPedido, Color> _getCorColuna(BuildContext context) => {
    EstadoPedido.emAberto: Theme.of(context).colorScheme.primaryContainer, // Azul mais intenso
    EstadoPedido.emAndamento: Colors.green.shade700, // Verde escuro (em andamento)
    EstadoPedido.entregaRetirada: Colors.orange.shade600, // Laranja suave
    EstadoPedido.finalizado: Colors.blueGrey.shade300, // Azul claro ou cinza
    EstadoPedido.cancelado: Colors.red.shade600, // Vermelho para cancelamento
  };

  bool _isKanbanView = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final sidebarWidth = 250.0;
    final availableWidth = screenWidth - sidebarWidth;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor, // Usando a cor do tema
        elevation: 1,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            'Pedidos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface, // Usando a cor adequada do tema
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          if (availableWidth >= 600) ...[
            ViewToggleButton(
              theme: theme, // Passando o tema
              isKanbanView: _isKanbanView,
              onToggle: (v) => setState(() => _isKanbanView = v),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          if (availableWidth < 600) {
            return _buildPedidosList();
          }

          if (availableWidth >= 600) {
            if (_isKanbanView) {
              return _buildKanban();
            } else {
              return _buildTabela();
            }
          }

          if (availableWidth > 1150) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: _buildKanban(),
            );
          }

          return _buildTabela();
        },
      ),
    );
  }

  Widget _buildPedidosList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          return _buildPedidoCard(pedido);
        },
      ),
    );
  }

  Widget _buildPedidoCard(Pedido pedido) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor, // Usando a cor do tema para o card
      child: InkWell(
        onTap: () => _openDetails(pedido),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedido #${pedido.numeroPedido}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface, // Usando a cor adequada
                ),
              ),
              const SizedBox(height: 8),
              Text('Cliente: ${pedido.nomeCliente}', style: theme.textTheme.bodyMedium),
              Text('Serviço: ${pedido.servico}', style: theme.textTheme.bodyMedium),
              Text('Status: ${pedido.estado.name}', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
                  _buildActionButtons(pedido),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Pedido pedido) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: Icon(LucideIcons.edit, size: 18, color: theme.iconTheme.color), // Usando a cor dos ícones do tema
          onPressed: () => _showSnackNotImpl(pedido),
        ),
        IconButton(
          icon: Icon(LucideIcons.trash, size: 18, color: theme.iconTheme.color), // Usando a cor dos ícones do tema
          onPressed: () => _removePedido(pedido),
        ),
      ],
    );
  }

  Widget _buildTabela() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Tabela(
        pedidos: pedidos,
        onEstadoChanged: _updatePedido,
        onDelete: _removePedido,
        onEdit: _showSnackNotImpl,
      ),
    );
  }

  Widget _buildKanban() {
    return Kanban(
      pedidos: pedidos,
      corColuna: _getCorColuna(context),
      onPedidoEstadoChanged: _updatePedido,
      onDelete: _removePedido,
      onTapDetails: _openDetails,
    );
  }

  void _updatePedido(Pedido pedido) {
    setState(() {
      final idx = pedidos.indexWhere((p) => p.id == pedido.id);
      if (idx != -1) pedidos[idx] = pedido;
    });
  }

  void _removePedido(Pedido pedido) {
    setState(() => pedidos.removeWhere((p) => p.id == pedido.id));
  }

  void _openDetails(Pedido pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: pedido)),
    );
  }

  void _showSnackNotImpl(Pedido pedido) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edição do pedido #${pedido.numeroPedido} não implementada')),
    );
  }
}

class ViewToggleButton extends StatelessWidget {
  final bool isKanbanView;
  final ValueChanged<bool> onToggle;
  final ThemeData theme;  // Recebendo o tema como parâmetro

  const ViewToggleButton({
    super.key,
    required this.isKanbanView,
    required this.onToggle,
    required this.theme,  // Adicionando o tema como parâmetro
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,  // Usando a cor do tema
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _ToggleIcon(
            icon: LucideIcons.layoutGrid,
            selected: isKanbanView,
            onTap: () => onToggle(true),
          ),
          _ToggleIcon(
            icon: LucideIcons.table,
            selected: !isKanbanView,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 20,
          color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
