import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:siga/Model/pedidos.dart';
import 'pedidos_card.dart'; // Supondo que PedidoCard esteja neste caminho

// A assinatura dos callbacks permanece a mesma.
typedef PedidoEstadoCallback = void Function(Pedido pedido, String novoEstado);
typedef PedidoCallback = void Function(Pedido pedido);

class Kanban extends StatefulWidget {
  final List<Pedido> pedidos;
  final Map<String, Color> corColuna;
  final PedidoEstadoCallback onPedidoEstadoChanged;
  final PedidoCallback onDelete;
  final PedidoCallback onTapDetails;

  const Kanban({
    super.key,
    required this.pedidos,
    required this.corColuna,
    required this.onPedidoEstadoChanged,
    required this.onDelete,
    required this.onTapDetails,
  });

  @override
  State<Kanban> createState() => _KanbanState();
}

class _KanbanState extends State<Kanban> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // A sua excelente lógica de scroll foi mantida.
  void _scrollHorizontal(double delta) {
    if (!_horizontalScrollController.hasClients) return;
    final min = _horizontalScrollController.position.minScrollExtent;
    final max = _horizontalScrollController.position.maxScrollExtent;
    final newOffset = (_horizontalScrollController.offset + delta).clamp(min, max);
    _horizontalScrollController.jumpTo(newOffset);
  }

  @override
  Widget build(BuildContext context) {
    // A lógica de agrupamento e ordenação foi mantida.
    final estadosOrdenados = EstadoPedido.values.map((e) => e.label).toList();
    final pedidosPorEstado = {
      for (var estadoLabel in estadosOrdenados)
        estadoLabel: widget.pedidos.where((p) => p.status == estadoLabel).toList()
          ..sort((a, b) => a.dataEntregaPrevista.compareTo(b.dataEntregaPrevista)),
    };

    return Listener(
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) _scrollHorizontal(signal.scrollDelta.dy);
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: estadosOrdenados.map((estadoLabel) {
              final lista = pedidosPorEstado[estadoLabel]!;
              return _KanbanColumn(
                estadoLabel: estadoLabel,
                pedidos: lista,
                corColuna: widget.corColuna[estadoLabel] ?? Colors.grey, // Fallback de cor
                onPedidoEstadoChanged: widget.onPedidoEstadoChanged,
                onDelete: widget.onDelete,
                onTapDetails: widget.onTapDetails,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// ==================== WIDGET DE COLUNA REFINADO ====================
// ===================================================================
class _KanbanColumn extends StatelessWidget {
  final String estadoLabel;
  final List<Pedido> pedidos;
  final Color corColuna;
  final PedidoEstadoCallback onPedidoEstadoChanged;
  final PedidoCallback onDelete;
  final PedidoCallback onTapDetails;

  const _KanbanColumn({
    required this.estadoLabel,
    required this.pedidos,
    required this.corColuna,
    required this.onPedidoEstadoChanged,
    required this.onDelete,
    required this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return DragTarget<Pedido>(
      onWillAcceptWithDetails: (details) => details.data.status != estadoLabel,
      onAcceptWithDetails: (details) => onPedidoEstadoChanged(details.data, estadoLabel),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          // 1. DESIGN DA COLUNA APRIMORADO
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: isHighlighted
                ? Border.all(color: theme.colorScheme.primary, width: 2.5)
                : null,
          ),
          child: Column(
            children: [
              // 2. CABEÇALHO INFORMATIVO
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(bottom: BorderSide(color: theme.dividerColor))
                ),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: corColuna, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(estadoLabel, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                    Text('${pedidos.length}', style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              // Conteúdo da coluna
              Expanded(
                child: pedidos.isEmpty
                    ? Center(child: Text('Arraste um pedido para cá', style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    return Draggable<Pedido>(
                      data: pedido,
                      // 3. FEEDBACK VISUAL MELHORADO
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 284,
                          child: Opacity(
                            opacity: 0.95,
                            child: Card(
                              elevation: 10, // Sombra mais pronunciada
                              child: PedidoCard(pedido: pedido),
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.4,
                        child: PedidoCard(
                          pedido: pedido,
                          onDelete: () => onDelete(pedido),
                          onTapDetails: () => onTapDetails(pedido),
                          // CORREÇÃO: O callback agora passa a String do novo estado diretamente.
                          onStatusChanged: (novoEstado) => onPedidoEstadoChanged(pedido, novoEstado),
                        ),
                      ),
                      child: PedidoCard(
                        pedido: pedido,
                        onDelete: () => onDelete(pedido),
                        onTapDetails: () => onTapDetails(pedido),
                        // CORREÇÃO: O callback agora passa a String do novo estado diretamente.
                        onStatusChanged: (novoEstado) => onPedidoEstadoChanged(pedido, novoEstado),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
