import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:siga/Model/pedidos.dart';

// As assinaturas dos callbacks estão corretas.
typedef PedidoEstadoCallback = void Function(Pedido pedido, String novoEstado);
typedef PedidoCallback = void Function(Pedido pedido);

class Tabela extends StatefulWidget {
  final List<Pedido> pedidos;
  final PedidoEstadoCallback onEstadoChanged;
  final PedidoCallback onDelete;
  final PedidoCallback onEdit;

  const Tabela({
    super.key,
    required this.pedidos,
    required this.onEstadoChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<Tabela> createState() => _TabelaState();
}

class _TabelaState extends State<Tabela> {
  int _sortColumnIndex = 2; // Padrão: ordenar por data de entrega
  bool _sortAscending = true;

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A lógica de ordenação foi mantida, pois está perfeita.
    List<Pedido> pedidosProcessados = List.from(widget.pedidos);
    pedidosProcessados.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0: comparison = a.numeroPedido.compareTo(b.numeroPedido); break;
        case 1: comparison = (a.cliente['nome'] ?? '').compareTo(b.cliente['nome'] ?? ''); break;
        case 2: comparison = a.dataEntregaPrevista.compareTo(b.dataEntregaPrevista); break;
        case 3: comparison = a.status.compareTo(b.status); break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return Column(
      children: [
        // O cabeçalho da tabela.
        _buildHeader(theme),
        const SizedBox(height: 8),
        // O corpo da tabela.
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.builder(
              itemCount: pedidosProcessados.length,
              itemBuilder: (context, index) {
                final pedido = pedidosProcessados[index];
                return _PedidoDataRow(
                  pedido: pedido,
                  onDelete: () => widget.onDelete(pedido),
                  onEdit: () => widget.onEdit(pedido),
                  onEstadoChanged: (novoEstado) => widget.onEstadoChanged(pedido, novoEstado),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor)
      ),
      child: Row(
        children: [
          _HeaderCell(label: "Pedido", flex: 2, sortIndex: 0, state: this),
          _HeaderCell(label: "Cliente", flex: 3, sortIndex: 1, state: this),
          _HeaderCell(label: "Entrega", flex: 2, sortIndex: 2, state: this),
          _HeaderCell(label: "Status", flex: 2, sortIndex: 3, state: this),
          const Expanded(flex: 1, child: Text("Ações", textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

// ===================================================================
// ==================== CLASSES AUXILIARES (ATUALIZADAS) =============
// ===================================================================

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final int sortIndex;
  final _TabelaState state;

  const _HeaderCell({required this.label, required this.flex, required this.sortIndex, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isSorted = state._sortColumnIndex == sortIndex;

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => state._onSort(sortIndex, isSorted ? !state._sortAscending : true),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              if (isSorted)
                Icon(state._sortAscending ? Icons.arrow_downward : Icons.arrow_upward, size: 16)
              else
                Icon(Icons.unfold_more, size: 16, color: theme.colorScheme.onSurfaceVariant)
            ],
          ),
        ),
      ),
    );
  }
}

class _PedidoDataRow extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ValueChanged<String> onEstadoChanged;

  const _PedidoDataRow({
    required this.pedido,
    required this.onDelete,
    required this.onEdit,
    required this.onEstadoChanged,
  });

  // Função de confirmação para o delete
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar exclusão"),
        content: Text("Deseja realmente excluir o pedido #${pedido.numeroPedido}?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancelar")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      onDelete();
    }
  }

  Color _getStatusColor(BuildContext context, String statusLabel) {
    final status = EstadoPedido.fromString(statusLabel);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Lógica de cores...
    switch (status) {
      case EstadoPedido.emAberto: return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      case EstadoPedido.emAndamento: return isDark ? Colors.amber.shade300 : Colors.amber.shade800;
      case EstadoPedido.entregaRetirada: return isDark ? Colors.orange.shade400 : Colors.orange.shade900;
      case EstadoPedido.finalizado: return isDark ? Colors.green.shade400 : Colors.green.shade800;
      case EstadoPedido.cancelado: return isDark ? Colors.red.shade400 : Colors.red.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final statusColor = _getStatusColor(context, pedido.status);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit, // O toque na linha inteira abre a edição
        hoverColor: theme.colorScheme.primary.withOpacity(0.05),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(16), child: Text('#${pedido.numeroPedido}', style: const TextStyle(fontWeight: FontWeight.bold)))),
              const VerticalDivider(width: 1),
              Expanded(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pedido.cliente['nome'] ?? 'Cliente'), Text(currencyFormatter.format(pedido.total), style: theme.textTheme.bodySmall)]))),
              const VerticalDivider(width: 1),
              Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(16), child: Text(DateFormat('dd/MM/yy').format(pedido.dataEntregaPrevista.toDate())))),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(pedido.status, textAlign: TextAlign.center, style: theme.textTheme.labelMedium?.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 1,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: "Mais ações",
                  // CORREÇÃO: O menu de status agora é gerado corretamente
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(LucideIcons.edit), title: Text('Editar'))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(enabled: false, child: Text('Mover para:', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...EstadoPedido.values.where((st) => st.label != pedido.status).map((st) =>
                        PopupMenuItem(value: st.label, child: Text(st.label))
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(LucideIcons.trash2, color: theme.colorScheme.error), title: Text('Excluir', style: TextStyle(color: theme.colorScheme.error)))),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context);
                    } else {
                      // Se não for 'edit' nem 'delete', é uma string de status.
                      onEstadoChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
