import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:siga/Pages/PedidosPage/Components/pedidos_card.dart';
import '../../../Model/pedidos.dart';

typedef PedidoCallback = void Function(Pedido pedido);

class Kanban extends StatefulWidget {
  final List<Pedido> pedidos;
  final Map<EstadoPedido, Color> corColuna;
  final Function(Pedido) onPedidoEstadoChanged;
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

  // Sua lógica de scroll horizontal foi mantida, pois já é excelente.
  void _scrollHorizontal(double delta) {
    if (!_horizontalScrollController.hasClients) return;
    final min = _horizontalScrollController.position.minScrollExtent;
    final max = _horizontalScrollController.position.maxScrollExtent;
    final newOffset = (_horizontalScrollController.offset + delta).clamp(min, max);
    _horizontalScrollController.jumpTo(newOffset);
  }

  @override
  Widget build(BuildContext context) {
    // Ordena os pedidos por estado para garantir a ordem das colunas
    final estadosOrdenados = EstadoPedido.values.toList();
    final pedidosPorEstado = {
      for (var estado in estadosOrdenados)
        estado: widget.pedidos.where((p) => p.estado == estado).toList()
          ..sort((a, b) => a.dataEntrega.compareTo(b.dataEntrega)),
    };

    return Listener(
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) _scrollHorizontal(signal.scrollDelta.dy);
      },
      child: ScrollConfiguration(
        // Permite arrastar o scroll com o mouse
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: estadosOrdenados.map((estado) {
              final lista = pedidosPorEstado[estado]!;
              return _KanbanColumn(
                estado: estado,
                pedidos: lista,
                corColuna: widget.corColuna[estado]!,
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
// ================ WIDGET DE COLUNA REATORADO =======================
// ===================================================================
class _KanbanColumn extends StatelessWidget {
  final EstadoPedido estado;
  final List<Pedido> pedidos;
  final Color corColuna;
  final Function(Pedido) onPedidoEstadoChanged;
  final PedidoCallback onDelete;
  final PedidoCallback onTapDetails;

  const _KanbanColumn({
    required this.estado,
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
      onWillAccept: (pedido) => pedido != null && pedido.estado != estado,
      onAccept: (pedido) => onPedidoEstadoChanged(pedido.copyWith(estado: estado)),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          // 1. DESIGN DA COLUNA APRIMORADO
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: isHighlighted
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. CABEÇALHO INFORMATIVO
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: corColuna, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        estado.label,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${pedidos.length}',
                      style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Conteúdo da coluna
              Expanded(
                child: pedidos.isEmpty
                    ? Center(child: Text('Nenhum pedido aqui', style: textTheme.bodyMedium))
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
                            opacity: 0.9,
                            child: Card(
                              elevation: 8,
                              child: PedidoCard(
                                pedido: pedido,
                                onDelete: () {}, // Desabilitado no feedback
                                onTapDetails: () {}, // Desabilitado no feedback
                              ),
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
                        ),
                      ),
                      child: PedidoCard(
                        pedido: pedido,
                        onDelete: () => onDelete(pedido),
                        onTapDetails: () => onTapDetails(pedido),
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
