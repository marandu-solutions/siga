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
        title: const Text("Confirmar exclusão"),
        content: Text("Deseja excluir o pedido #${widget.pedido.numeroPedido}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final minutos = DateTime.now().difference(widget.pedido.dataPedido).inMinutes;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Semantics(
        label:
        "Pedido #${widget.pedido.numeroPedido}, $minutos minutos, clique para ${_isExpanded ? 'retrair' : 'expandir'}",
        child: _buildCard(minutos),
      ),
    );
  }

  Widget _buildCard(int minutos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: número + tempo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Número do pedido com borda
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "#${widget.pedido.numeroPedido}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),

                // Tempo em minutos
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text(
                        "$minutos min",
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Detalhes expandidos
            if (_isExpanded) ...[
              _infoRow(Icons.person_outline, "Cliente: ${widget.pedido.nomeCliente}"),
              _infoRow(Icons.work_outline, "Serviço: ${widget.pedido.servico}"),
              _infoRow(
                Icons.format_list_numbered,
                "Qtd: ${widget.pedido.quantidade} | Tamanho: ${widget.pedido.tamanho}",
              ),
              _infoRow(
                Icons.color_lens,
                "Malha: ${widget.pedido.tipoMalha} | Cor: ${widget.pedido.cor}",
              ),
              _infoRow(
                Icons.attach_money,
                "Valor: R\$ ${widget.pedido.valorTotal.toStringAsFixed(2)}",
              ),
              if (widget.pedido.observacoes.isNotEmpty)
                _infoRow(Icons.note_outlined, "Obs: ${widget.pedido.observacoes}"),

              const SizedBox(height: 12),

              // Botão ver detalhes
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: widget.onTapDetails,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6845C3),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF6845C3)),
                    ),
                  ),
                  child: const Text(
                    "Ver detalhes",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Rodapé: ícones ou expand toggle + delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isExpanded) ..._buildCollapsedIcons(),

                // Toggle expand/contract
                Semantics(
                  label: _isExpanded ? "Botão retrair" : "Botão expandir",
                  child: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),

                // Botão de deletar
                if (widget.onDelete != null) ...[
                  const SizedBox(width: 10),
                  Tooltip(
                    message: "Excluir pedido",
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await _confirmDelete(context);
                        if (confirm) {
                          widget.onDelete!();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Pedido #${widget.pedido.numeroPedido} excluído")),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.red,
                      ),
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

  // --- Métodos auxiliares ---

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15.5,
                fontFamily: 'Roboto',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCollapsedIcons() {
    return [
      const Icon(Icons.person_outline, size: 18, color: Colors.black54),
      const SizedBox(width: 8),
      const Icon(Icons.work_outline, size: 18, color: Colors.black54),
      const SizedBox(width: 8),
      const Icon(Icons.format_list_numbered, size: 18, color: Colors.black54),
      const SizedBox(width: 8),
      const Icon(Icons.color_lens, size: 18, color: Colors.black54),
      const SizedBox(width: 8),
      const Icon(Icons.attach_money, size: 18, color: Colors.black54),
      if (widget.pedido.observacoes.isNotEmpty) ...[
        const SizedBox(width: 8),
        const Icon(Icons.note_outlined, size: 18, color: Colors.black54),
      ],
      const SizedBox(width: 8),
    ];
  }
}
