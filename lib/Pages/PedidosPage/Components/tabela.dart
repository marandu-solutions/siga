import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:siga/Model/pedidos.dart';



class Tabela extends StatefulWidget {
  final List<Pedido> pedidos;
  // ✅ Callback atualizado para passar uma String de status
  final Function(Pedido pedido, String novoEstado) onEstadoChanged;
  final Function(Pedido pedido) onDelete;
  final Function(Pedido pedido) onEdit;

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
  // ❌ REMOVIDO: A lógica de filtro e busca agora é da PedidosPage.
  // final TextEditingController _searchController = TextEditingController();
  // EstadoPedido? _filtroEstado;

  // ✅ O estado da ordenação é local e mantido aqui.
  int _sortColumnIndex = 2; // Padrão: ordenar por data de entrega
  bool _sortAscending = true;

  @override
  void dispose() {
    // _searchController.dispose();
    super.dispose();
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    // ✅ A ordenação é aplicada na lista recebida.
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ❌ REMOVIDO: O cabeçalho com título e controles agora está na PedidosPage.
        // Text("Gestão de Pedidos", ...),
        // _buildControls(context),
        
        Expanded(
          child: Container(
            width: double.infinity, // Garante que o container ocupe toda a largura
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildHeader(theme),
                Expanded(
                  child: pedidosProcessados.isEmpty
                      ? const Center(child: Text('Nenhum pedido encontrado.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
              ],
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
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
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
  // ✅ Callback agora recebe uma String
  final ValueChanged<String> onEstadoChanged;

  const _PedidoDataRow({
    required this.pedido,
    required this.onDelete,
    required this.onEdit,
    required this.onEstadoChanged,
  });

  Color _getStatusColor(BuildContext context, String statusLabel) {
    final status = EstadoPedido.fromString(statusLabel); // Converte para o enum para a lógica
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    // ✅ Pega a cor baseada na String de status
    final statusColor = _getStatusColor(context, pedido.status);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(padding: const EdgeInsets.all(16), child: Text(pedido.numeroPedido, style: const TextStyle(fontWeight: FontWeight.bold))),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 3,
              child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ✅ Acessa o nome do cliente pelo mapa
                Text(pedido.cliente['nome'] ?? 'Cliente sem nome'), 
                // ✅ Usa o campo 'total' do pedido
                Text(currencyFormatter.format(pedido.total), style: theme.textTheme.bodySmall)
              ])),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 2,
              // ✅ Usa o Timestamp do Firestore, convertendo para DateTime
              child: Padding(padding: const EdgeInsets.all(16), child: Text(DateFormat('dd/MM/yy').format(pedido.dataEntregaPrevista.toDate()))),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pedido.status, // ✅ Exibe a String de status diretamente
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 1,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  } else {
                    // Se não for 'edit' nem 'delete', é um status.
                    onEstadoChanged(value);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuDivider(),
                  // ✅ O menu de status agora é gerado a partir do enum, mas passa a String
                  ...EstadoPedido.values.where((st) => st.label != pedido.status).map((st) => 
                    PopupMenuItem(value: st.label, child: Text('Mover para "${st.label}"'))
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: theme.colorScheme.error))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}