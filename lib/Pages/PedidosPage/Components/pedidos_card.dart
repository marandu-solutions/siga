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
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final duration = DateTime.now().difference(widget.pedido.dataPedido);
    final minutos = duration.inMinutes;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Semantics(
        label: "Pedido #${widget.pedido.numeroPedido}, $minutos minutos, clique para ${_isExpanded ? 'retrair' : 'expandir'}",
        child: _buildCard(minutos),
      ),
    );
  }

  Widget _buildCard(int minutos) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${widget.pedido.numeroPedido}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
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
            if (_isExpanded) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    "Cliente: ${widget.pedido.nomeCliente}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.work_outline, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    "Serviço: ${widget.pedido.servico}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.format_list_numbered, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    "Qtd: ${widget.pedido.quantidade} | Tamanho: ${widget.pedido.tamanho}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.color_lens, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    "Malha: ${widget.pedido.tipoMalha} | Cor: ${widget.pedido.cor}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    "Valor: R\$ ${widget.pedido.valorTotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              if (widget.pedido.observacoes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.note_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      "Obs: ${widget.pedido.observacoes}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
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
                      color: Color(0xFF6845C3),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isExpanded) ...[
                  const Icon(Icons.person_outline, size: 18, color: Colors.black54),
                  const SizedBox(width: 10),
                  const Icon(Icons.work_outline, size: 18, color: Colors.black54),
                  const SizedBox(width: 10),
                  const Icon(Icons.format_list_numbered, size: 18, color: Colors.black54),
                  const SizedBox(width: 10),
                  const Icon(Icons.color_lens, size: 18, color: Colors.black54),
                  const SizedBox(width: 10),
                  const Icon(Icons.attach_money, size: 18, color: Colors.black54),
                  if (widget.pedido.observacoes.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.note_outlined, size: 18, color: Colors.black54),
                  ],
                  const SizedBox(width: 10),
                ],
                Semantics(
                  label: _isExpanded ? "Botão retrair" : "Botão expandir",
                  child: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
                if (widget.onDelete != null) ...[
                  const SizedBox(width: 10),
                  Semantics(
                    label: "Botão excluir pedido",
                    child: Tooltip(
                      message: "Excluir pedido",
                      child: GestureDetector(
                        onTap: () async {
                          bool confirm = await _confirmDelete(context);
                          if (confirm) {
                            widget.onDelete!();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Pedido #${widget.pedido.numeroPedido} excluído")),
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
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}