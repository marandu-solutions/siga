import 'package:flutter/material.dart';
import 'package:siga/Pages/PedidosPage/Components/pedidos_card.dart';
import '../../../Model/pedidos.dart';

class Kanban extends StatefulWidget {
  final List<Pedido> pedidos;
  final Map<EstadoPedido, Color> corColuna;
  final Function(Pedido) onPedidoEstadoChanged;
  final Function(Pedido) onDelete;
  final Function(Pedido) onTapDetails;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLightMode = theme.brightness == Brightness.light;

    final headerColor = isLightMode ? Colors.white : Colors.grey.shade400;

    final pedidosPorEstado = {
      for (var estado in EstadoPedido.values)
        estado: widget.pedidos
            .where((p) => p.estado == estado)
            .toList()
          ..sort((a, b) => a.dataPedido.compareTo(b.dataPedido)),
    };

    return Padding(
      padding: const EdgeInsets.all(12.0),
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
              final pedidosEstado = pedidosPorEstado[estado]!;
              final corFundo = widget.corColuna[estado]!;

              final ScrollController verticalScrollController = ScrollController();

              return DragTarget<Pedido>(
                onWillAccept: (pedido) {
                  return pedido != null && pedido.estado != estado;
                },
                onAccept: (pedido) {
                  widget.onPedidoEstadoChanged(pedido.copyWith(estado: estado));
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: corFundo.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: candidateData.isNotEmpty
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: headerColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Semantics(
                            label: "Coluna ${estado.label}",
                            child: Text(
                              estado.label,
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: pedidosEstado.isEmpty
                              ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                "Nenhum pedido",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                              : Scrollbar(
                            controller: verticalScrollController,
                            thumbVisibility: true,
                            child: ListView.builder(
                              controller: verticalScrollController,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: pedidosEstado.length,
                              itemBuilder: (context, index) {
                                final pedido = pedidosEstado[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Dismissible(
                                    key: Key(pedido.id.toString()),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: colorScheme.error,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Icon(
                                        Icons.delete,
                                        color: colorScheme.onError,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      return await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            "Confirmar exclusão",
                                            style: textTheme.titleMedium?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          content: Text(
                                            "Deseja excluir o pedido #${pedido.numeroPedido}?",
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          backgroundColor: colorScheme.surface,
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text(
                                                "Cancelar",
                                                style: TextStyle(
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: Text(
                                                "Excluir",
                                                style: TextStyle(
                                                  color: colorScheme.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    onDismissed: (direction) {
                                      widget.onDelete(pedido);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Pedido #${pedido.numeroPedido} excluído",
                                            style: TextStyle(
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          backgroundColor: colorScheme.surface,
                                        ),
                                      );
                                    },
                                    child: Draggable<Pedido>(
                                      data: pedido,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Opacity(
                                          opacity: 0.75,
                                          child: PedidoCard(
                                            pedido: pedido,
                                            onDelete: () => widget.onDelete(pedido),
                                            onTapDetails: () => widget.onTapDetails(pedido),
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: PedidoCard(pedido: pedido),
                                      ),
                                      child: PedidoCard(
                                        pedido: pedido,
                                        onDelete: () => widget.onDelete(pedido),
                                        onTapDetails: () => widget.onTapDetails(pedido),
                                      ),
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
    );
  }
}