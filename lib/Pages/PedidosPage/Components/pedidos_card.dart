import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../Model/pedidos.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;

  const PedidoCard({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final duration = DateTime.now().difference(pedido.dataPedido);
    final minutos = duration.inMinutes;

    return LongPressDraggable<Pedido>(
      data: pedido,
      feedback: Opacity(
        opacity: 0.8,
        child: SizedBox(
          width: 280,
          child: _buildCard(minutos),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCard(minutos),
      ),
      child: _buildCard(minutos),
    );
  }

  Widget _buildCard(int minutos) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topo com número do pedido e tempo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${pedido.numeroPedido}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.clock4, size: 14),
                      const SizedBox(width: 4),
                      Text("${minutos}min",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Cliente: ${pedido.nomeCliente}",
              style: const TextStyle(color: Colors.black),
            ),
            Text(
              "Serviço: ${pedido.servico}",
              style: const TextStyle(color: Colors.black),
            ),
            Text(
              "Qtd: ${pedido.quantidade} | Tamanho: ${pedido.tamanho}",
              style: const TextStyle(color: Colors.black),
            ),
            Text(
              "Malha: ${pedido.tipoMalha} | Cor: ${pedido.cor}",
              style: const TextStyle(color: Colors.black),
            ),
            Text(
              "Valor: R\$ ${pedido.valorTotal.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.black),
            ),
            if (pedido.observacoes.isNotEmpty)
              Text(
                "Obs: ${pedido.observacoes}",
                style: const TextStyle(color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}
