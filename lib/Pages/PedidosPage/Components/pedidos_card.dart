import 'package:flutter/material.dart';
import '../../../Model/pedidos.dart';

class PedidoCard extends StatefulWidget {
  final Pedido pedido;
  final VoidCallback? onDelete;
  final VoidCallback? onTapDetails;

  const PedidoCard({
    super.key,
    required this.pedido,
    this.onDelete,
    this.onTapDetails,
  });

  @override
  State<PedidoCard> createState() => _PedidoCardState();
}

class _PedidoCardState extends State<PedidoCard> {
  bool _isExpanded = false;

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirmar exclusão",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          "Deseja excluir o pedido #${widget.pedido.numeroPedido}?",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Excluir",
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final minutos = DateTime.now().difference(widget.pedido.dataPedido).inMinutes;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Semantics(
        label:
        "Pedido #${widget.pedido.numeroPedido}, $minutos minutos, clique para ${_isExpanded ? 'retrair' : 'expandir'}",
        child: _buildCard(minutos, cs, tt),
      ),
    );
  }

  Widget _buildCard(int minutos, ColorScheme cs, TextTheme tt) {
    final valorTotal = widget.pedido.itens.fold<double>(
      0.0,
          (sum, item) => sum + (item.preco * item.quantidade),
    );

    final resumoPedido = widget.pedido.itens
        .map((e) => "${e.quantidade}x ${e.nome}")
        .join(", ");

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com número do pedido e tempo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.onSurface.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "#${widget.pedido.numeroPedido}",
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        "$minutos min",
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Nome do cliente (sempre visível)
            Text(
              "Cliente: ${widget.pedido.nomeCliente}",
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            // Resumo do pedido (sempre visível)
            Text(
              "Pedido: $resumoPedido",
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),

            // Conteúdo expandido
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              // Detalhes completos dos itens
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fastfood, size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Itens:",
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...widget.pedido.itens.asMap().entries.map((entry) {
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 4),
                              child: Text(
                                "${item.quantidade}x ${item.nome} - R\$ ${(item.preco * item.quantidade).toStringAsFixed(2)}",
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _infoRow(Icons.attach_money,
                  "Valor: R\$ ${valorTotal.toStringAsFixed(2)}", cs, tt),
              if (widget.pedido.observacoes.isNotEmpty)
                _infoRow(Icons.note_outlined,
                    "Obs: ${widget.pedido.observacoes}", cs, tt),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: widget.onTapDetails,
                  style: TextButton.styleFrom(
                    foregroundColor: cs.primary,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: cs.primary),
                    ),
                  ),
                  child: const Text(
                    "Ver detalhes",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],

            // Rodapé com botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
                if (widget.onDelete != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      if (await _confirmDelete(context)) {
                        widget.onDelete!();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Pedido #${widget.pedido.numeroPedido} excluído"),
                          ),
                        );
                      }
                    },
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: cs.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: tt.bodyMedium?.copyWith(color: cs.onSurface),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}