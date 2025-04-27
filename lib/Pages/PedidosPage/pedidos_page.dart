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

  Map<EstadoPedido, Color> _getCorColuna(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return {
      EstadoPedido.emAberto: const Color(0xFF0288D1), // Azul vibrante
      EstadoPedido.emAndamento: const Color(0xFFFFA726), // Laranja
      EstadoPedido.entregaRetirada: const Color(0xFF7B1FA2), // Roxo
      EstadoPedido.finalizado: const Color(0xFF388E3C), // Verde
      EstadoPedido.cancelado: const Color(0xFFD32F2F), // Vermelho
    };
  }

  bool _isKanbanView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Pedidos',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          ViewToggleButton(
            isKanbanView: _isKanbanView,
            onToggle: (isKanban) {
              setState(() {
                _isKanbanView = isKanban;
              });
            },
          ),
        ],
      ),
      body: _isKanbanView
          ? Kanban(
        pedidos: pedidos,
        corColuna: _getCorColuna(context),
        onPedidoEstadoChanged: (pedido) {
          setState(() {
            final index = pedidos.indexWhere((p) => p.id == pedido.id);
            if (index != -1) {
              pedidos[index] = pedido;
            }
          });
        },
        onDelete: (pedido) {
          setState(() {
            pedidos.removeWhere((p) => p.id == pedido.id);
          });
        },
        onTapDetails: (pedido) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PedidoDetailsPage(pedido: pedido),
            ),
          );
        },
      )
          : Tabela(
        pedidos: pedidos,
        onEstadoChanged: (pedido) {
          setState(() {
            final index = pedidos.indexWhere((p) => p.id == pedido.id);
            if (index != -1) {
              pedidos[index] = pedido;
            }
          });
        },
        onDelete: (pedido) {
          setState(() {
            pedidos.removeWhere((p) => p.id == pedido.id);
          });
        },
        onEdit: (pedido) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Edição do pedido #${pedido.numeroPedido} não implementada",
                style: TextStyle(color: colorScheme.onSurface),
              ),
              backgroundColor: colorScheme.surface,
            ),
          );
        },
      ),
    );
  }
}

class ViewToggleButton extends StatelessWidget {
  final bool isKanbanView;
  final Function(bool) onToggle;

  const ViewToggleButton({
    super.key,
    required this.isKanbanView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _ToggleButtonItem(
            icon: LucideIcons.layoutGrid,
            isSelected: isKanbanView,
            onPressed: () => onToggle(true),
            tooltip: 'Visualização Kanban',
          ),
          _ToggleButtonItem(
            icon: LucideIcons.table,
            isSelected: !isKanbanView,
            onPressed: () => onToggle(false),
            tooltip: 'Visualização em Tabela',
          ),
        ],
      ),
    );
  }
}

class _ToggleButtonItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;
  final String tooltip;

  const _ToggleButtonItem({
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}