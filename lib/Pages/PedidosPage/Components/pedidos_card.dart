import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:siga/Model/pedidos.dart';


class PedidoCard extends StatefulWidget {
  final Pedido pedido;
  final VoidCallback? onDelete;
  final VoidCallback? onTapDetails;
  // ✅ O callback agora passa a String do novo estado.
  final ValueChanged<String>? onStatusChanged;

  const PedidoCard({
    super.key,
    required this.pedido,
    this.onDelete,
    this.onTapDetails,
    this.onStatusChanged,
  });

  @override
  State<PedidoCard> createState() => _PedidoCardState();
}

class _PedidoCardState extends State<PedidoCard> {
  bool _isExpanded = false;

  // O diálogo de confirmação não precisa de alterações na sua lógica.
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar exclusão"),
        content: Text("Deseja excluir o pedido #${widget.pedido.numeroPedido}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Excluir", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    ) ?? false;
  }

  // ✅ O método _statusColor agora recebe uma String e usa o enum internamente.
  Color _statusColor(String statusLabel) {
    final status = EstadoPedido.fromString(statusLabel); // Converte a String para o enum
    final brightness = Theme.of(context).brightness;
    
    // O resto da lógica de cores permanece o mesmo
    if (brightness == Brightness.dark) {
      switch (status) {
        case EstadoPedido.emAberto: return const Color(0xFF7016BD);
        case EstadoPedido.emAndamento: return const Color(0xFFC5960D);
        case EstadoPedido.entregaRetirada: return const Color(0xFFB13D10);
        case EstadoPedido.finalizado: return const Color(0xFF059E05);
        case EstadoPedido.cancelado: return const Color(0xFF9E051C);
      }
    } else {
      switch (status) {
        case EstadoPedido.emAberto: return Colors.purple.shade500;
        case EstadoPedido.emAndamento: return Colors.amber.shade600;
        case EstadoPedido.entregaRetirada: return Colors.orange.shade700;
        case EstadoPedido.finalizado: return Colors.green.shade800;
        case EstadoPedido.cancelado: return Colors.red.shade800;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    // ✅ Passa a string do status para obter a cor.
    final statusColor = _statusColor(widget.pedido.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: statusColor, width: 5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, textTheme, cs, statusColor),
                const SizedBox(height: 12),
                _buildCustomerInfo(textTheme, cs),
                const SizedBox(height: 12),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded ? _buildExpandedContent(textTheme, cs) : _buildCollapsedContent(textTheme, cs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme tt, ColorScheme cs, Color statusColor) {
    // ✅ Usa .toDate() para converter o Timestamp do Firestore em DateTime
    final minutos = DateTime.now().difference(widget.pedido.dataPedido.toDate()).inMinutes;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              // ✅ Usa a string de status diretamente.
              widget.pedido.status.toUpperCase(),
              style: tt.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(LucideIcons.clock, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text("$minutos min", style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const Spacer(),
        _buildActionsMenu(context),
      ],
    );
  }

  Widget _buildCustomerInfo(TextTheme tt, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Acessa o nome do cliente através do mapa.
        Text(widget.pedido.cliente['nome'] ?? 'Cliente sem nome', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text('Pedido #${widget.pedido.numeroPedido}', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildCollapsedContent(TextTheme tt, ColorScheme cs) {
    final resumoPedido = widget.pedido.itens.map((e) => "${e.quantidade}x ${e.nome}").join(", ");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(resumoPedido, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
        Icon(Icons.expand_more, color: cs.onSurfaceVariant),
      ],
    );
  }

  Widget _buildExpandedContent(TextTheme tt, ColorScheme cs) {
    // ✅ Usa o campo 'total' do pedido, que já vem calculado.
    final valorTotal = widget.pedido.total;
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text("Itens do Pedido:", style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...widget.pedido.itens.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text("${item.quantidade}x ${item.nome}")),
              Text(currencyFormatter.format(item.preco * item.quantidade)),
            ],
          ),
        )),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text("Total: ", style: tt.bodyMedium),
          Text(currencyFormatter.format(valorTotal), style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ]),
        if (widget.pedido.observacoes.isNotEmpty) ...[
          const Divider(height: 24),
          Text("Observações:", style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.pedido.observacoes, style: tt.bodyMedium),
        ],
        const SizedBox(height: 8),
        Center(child: Icon(Icons.expand_less, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'details') {
          widget.onTapDetails?.call();
        } else if (value == 'delete') {
          if (await _confirmDelete(context)) widget.onDelete?.call();
        } else {
          // ✅ Se o valor não for 'details' nem 'delete',
          // significa que é uma string de status.
          widget.onStatusChanged?.call(value);
        }
      },
      itemBuilder: (context) => [
        if (widget.onTapDetails != null) const PopupMenuItem(value: 'details', child: ListTile(leading: Icon(LucideIcons.fileText), title: Text('Ver Detalhes'))),
        
        // ✅ O menu de mudança de status agora usa Strings como valor.
        if (widget.onStatusChanged != null)
          ...EstadoPedido.values.where((st) => st.label != widget.pedido.status).map((st) => 
            PopupMenuItem(
              value: st.label, 
              child: Text('Mover para "${st.label}"')
            )
          ),

        if (widget.onDelete != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(leading: Icon(LucideIcons.trash2, color: Theme.of(context).colorScheme.error), title: Text('Excluir Pedido', style: TextStyle(color: Theme.of(context).colorScheme.error))),
          ),
        ]
      ],
    );
  }
}