import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../Model/pedidos.dart';

class Tabela extends StatefulWidget {
  final List<Pedido> pedidos;
  final Function(Pedido) onEstadoChanged;
  final Function(Pedido) onDelete;
  final Function(Pedido) onEdit;

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
  final TextEditingController _searchController = TextEditingController();
  EstadoPedido? _filtroEstado;
  int _sortColumnIndex = 2; // Padrão: ordenar por data de entrega
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
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

    List<Pedido> pedidosProcessados = widget.pedidos.where((p) {
      final busca = _searchController.text.toLowerCase();
      final okTexto = p.numeroPedido.contains(busca) || p.nomeCliente.toLowerCase().contains(busca);
      final okEstado = _filtroEstado == null || p.estado == _filtroEstado;
      return okTexto && okEstado;
    }).toList();

    pedidosProcessados.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0: comparison = a.numeroPedido.compareTo(b.numeroPedido); break;
        case 1: comparison = a.nomeCliente.compareTo(b.nomeCliente); break;
        case 2: comparison = a.dataEntrega.compareTo(b.dataEntrega); break;
        case 3: comparison = a.estado.index.compareTo(b.estado.index); break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gestão de Pedidos", style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildControls(context),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
                        onEstadoChanged: (novoEstado) => widget.onEstadoChanged(pedido.copyWith(estado: novoEstado)),
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

  // MÉTODO DE CONTROLES CORRIGIDO PARA O TEMA ESCURO
  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);

    // Aplicando um estilo de input que funciona em ambos os temas
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: inputDecoration.copyWith(
              hintText: "Pesquisar por nº ou cliente...",
              prefixIcon: const Icon(LucideIcons.search),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<EstadoPedido?>(
            value: _filtroEstado,
            decoration: inputDecoration.copyWith(labelText: 'Status'),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: null, child: Text("Todos os Status")),
              ...EstadoPedido.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))),
            ],
            onChanged: (v) => setState(() => _filtroEstado = v),
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
  final ValueChanged<EstadoPedido> onEstadoChanged;

  const _PedidoDataRow({
    required this.pedido,
    required this.onDelete,
    required this.onEdit,
    required this.onEstadoChanged,
  });

  Color _getStatusColor(BuildContext context, EstadoPedido status) {
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
    final valorTotal = pedido.itens.fold<double>(0.0, (sum, item) => sum + (item.preco * item.quantidade));
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final statusColor = _getStatusColor(context, pedido.estado);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(padding: const EdgeInsets.all(16), child: Text('#${pedido.numeroPedido}', style: const TextStyle(fontWeight: FontWeight.bold))),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 3,
              child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pedido.nomeCliente), Text(currencyFormatter.format(valorTotal), style: theme.textTheme.bodySmall)])),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 2,
              child: Padding(padding: const EdgeInsets.all(16), child: Text(DateFormat('dd/MM/yy').format(pedido.dataEntrega))),
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
                    pedido.estado.label,
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
                  if (value == 'edit') onEdit();
                  else if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(
                    child: PopupMenuButton<EstadoPedido>(
                      onSelected: onEstadoChanged,
                      child: const Text('Mudar Status'),
                      itemBuilder: (_) => EstadoPedido.values.map((st) => PopupMenuItem(value: st, child: Text(st.label))).toList(),
                    ),
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
