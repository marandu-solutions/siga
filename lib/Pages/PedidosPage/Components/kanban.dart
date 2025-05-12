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

  void _scrollHorizontal(double delta) {
    if (!_horizontalScrollController.hasClients) return;
    final min = _horizontalScrollController.position.minScrollExtent;
    final max = _horizontalScrollController.position.maxScrollExtent;
    final newOffset = (_horizontalScrollController.offset + delta).clamp(min, max);
    _horizontalScrollController.jumpTo(newOffset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerColor = theme.colorScheme.surface;

    final pedidosPorEstado = {
      for (var estado in EstadoPedido.values)
        estado: widget.pedidos
            .where((p) => p.estado == estado)
            .toList()
          ..sort((a, b) => a.dataEntrega.compareTo(b.dataEntrega)),
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Listener(
        onPointerSignal: (signal) {
          if (signal is PointerScrollEvent) {
            // rola horizontal ao girar roda do mouse, com clamp
            _scrollHorizontal(signal.scrollDelta.dy);
          }
        },
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            // arrasta a tela com mouse/toque, com clamp
            _scrollHorizontal(-details.delta.dx);
          },
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: EstadoPedido.values.map((estado) {
                  final lista = pedidosPorEstado[estado]!;
                  final corFundo = widget.corColuna[estado]!;
                  final verticalController = ScrollController();

                  return DragTarget<Pedido>(
                    onWillAccept: (pedido) => pedido != null && pedido.estado != estado,
                    onAccept: (pedido) => widget.onPedidoEstadoChanged(
                      pedido.copyWith(estado: estado),
                    ),
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: corFundo.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: candidateData.isNotEmpty
                              ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow,
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho da coluna
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: headerColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                estado.label,
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            // Conteúdo
                            Expanded(
                              child: lista.isEmpty
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'Nenhum pedido',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                        color: theme
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                        fontSize: 16),
                                  ),
                                ),
                              )
                                  : Scrollbar(
                                controller: verticalController,
                                thumbVisibility: true,
                                child: ListView.builder(
                                  controller: verticalController,
                                  physics:
                                  const AlwaysScrollableScrollPhysics(),
                                  itemCount: lista.length,
                                  itemBuilder: (context, index) {
                                    final pedido = lista[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Draggable<Pedido>(
                                        data: pedido,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: SizedBox(
                                            width: 280,
                                            child: Opacity(
                                              opacity: 0.75,
                                              child: PedidoCard(
                                                pedido: pedido,
                                                onDelete: () =>
                                                    widget.onDelete(pedido),
                                                onTapDetails: () =>
                                                    widget.onTapDetails(pedido),
                                              ),
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: PedidoCard(
                                            pedido: pedido,
                                            onDelete: () =>
                                                widget.onDelete(pedido),
                                            onTapDetails: () =>
                                                widget.onTapDetails(pedido),
                                          ),
                                        ),
                                        child: PedidoCard(
                                          pedido: pedido,
                                          onDelete: () =>
                                              widget.onDelete(pedido),
                                          onTapDetails: () =>
                                              widget.onTapDetails(pedido),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
