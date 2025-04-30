import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../Model/pedidos.dart';
import 'Components/kanban.dart';
import 'Components/tabela.dart';
import 'Components/pedido_details_page.dart';

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
    EstadoPedido.emAberto: const Color(0xFF5A9FCF),
    EstadoPedido.emAndamento: const Color(0xFF5CAF7C),
    EstadoPedido.entregaRetirada: const Color(0xFFA87ECF),
    EstadoPedido.finalizado: const Color(0xFF7ECF9A),
    EstadoPedido.cancelado: const Color(0xFFCF7E7E),
  };

  bool _isKanbanView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F2),
        elevation: 1,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            'Pedidos',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          if (screenWidth >= 600) ...[
            ViewToggleButton(
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

          if (w < 600) return _buildTabela();

          if (!_isKanbanView) return _buildTabela();

          // Kanban em telas >= 600
          if (w < 900) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: SizedBox(
                width: 900,
                child: _buildKanban(),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: _buildKanban(),
          );
        },
      ),
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

  const ViewToggleButton({
    super.key,
    required this.isKanbanView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3F58),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE1BEE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 20,
          color: selected ? Colors.black87 : Colors.white38,
        ),
      ),
    );
  }
}
