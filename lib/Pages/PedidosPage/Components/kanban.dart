import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:siga/Model/pedidos.dart';


import 'pedidos_card.dart'; // Supondo que PedidoCard esteja neste caminho

// ✅ Assinatura do callback atualizada: passa o Pedido e o novo status (String).
typedef PedidoEstadoCallback = void Function(Pedido pedido, String novoEstado);
typedef PedidoCallback = void Function(Pedido pedido);

class Kanban extends StatefulWidget {
  final List<Pedido> pedidos;
  final Map<String, Color> corColuna; // ✅ Chave agora é String
  final PedidoEstadoCallback onPedidoEstadoChanged; // ✅ Callback atualizado
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
    // ✅ Agora usamos os 'labels' (Strings) do enum para ordenar e agrupar.
    final estadosOrdenados = EstadoPedido.values.map((e) => e.label).toList();

    // ✅ O agrupamento agora compara a propriedade `p.status` (String).
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
            // Mapeamos sobre a lista de Strings de estado
            children: estadosOrdenados.map((estadoLabel) {
              final lista = pedidosPorEstado[estadoLabel]!;
              return _KanbanColumn(
                estadoLabel: estadoLabel, // Passa a String do estado
                pedidos: lista,
                corColuna: widget.corColuna[estadoLabel]!,
                onPedidoEstadoChanged: widget.onPedidoEstadoChanged, // Passa o novo callback
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
// ==================== WIDGET DE COLUNA ATUALIZADO ====================
// ===================================================================
class _KanbanColumn extends StatelessWidget {
  final String estadoLabel; // ✅ Recebe a String do estado
  final List<Pedido> pedidos;
  final Color corColuna;
  final PedidoEstadoCallback onPedidoEstadoChanged; // ✅ Recebe o novo callback
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
      // ✅ A lógica de aceitar o drop compara a propriedade 'status' do pedido
      onWillAcceptWithDetails: (details) => details.data.status != estadoLabel,
      
      // ✅ AO ACEITAR: Chama o novo callback com o pedido e o novo estado (String).
      // Não modifica mais o objeto aqui. Apenas informa a ação.
      onAcceptWithDetails: (details) => onPedidoEstadoChanged(details.data, estadoLabel),
      
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: isHighlighted
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        estadoLabel, // ✅ Exibe a String do estado
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
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: 284,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: Card(
                                    elevation: 8,
                                    // PedidoCard não precisa de alterações na sua definição,
                                    // pois ele já recebe um objeto Pedido.
                                    child: PedidoCard(
                                      pedido: pedido,
                                      onDelete: () {}, // Ação desabilitada no feedback visual
                                      onTapDetails: () {}, // Ação desabilitada
                                      onStatusChanged: (_) {}, // Ação desabilitada
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
                                onStatusChanged: (novoEstado) => onPedidoEstadoChanged(pedido, novoEstado as String),
                              ),
                            ),
                            child: PedidoCard(
                              pedido: pedido,
                              onDelete: () => onDelete(pedido),
                              onTapDetails: () => onTapDetails(pedido),
                              onStatusChanged: (novoEstado) => onPedidoEstadoChanged(pedido, novoEstado as String),
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