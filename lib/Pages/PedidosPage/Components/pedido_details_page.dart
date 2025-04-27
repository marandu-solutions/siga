import 'package:flutter/material.dart';
import '../../../Model/pedidos.dart';

class PedidoDetailsPage extends StatelessWidget {
  final Pedido pedido;

  const PedidoDetailsPage({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pedido #${pedido.numeroPedido}"),
        backgroundColor: const Color(0xFF1E1E1E),
        automaticallyImplyLeading: false, // Remove a seta de voltar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cliente: ${pedido.nomeCliente}",
              style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 12),
            Text(
              "Telefone: ${pedido.telefoneCliente}",
              style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 12),
            Text(
              "Serviço: ${pedido.servico}",
              style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 12),
            Text(
              "Quantidade: ${pedido.quantidade}",
              style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 12),
            Text(
              "Tamanho: ${pedido.tamanho}",
              style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 12),
            Text(
              "Malha: ${pedido.tipoMalha}",
              style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 12),
            Text(
              "Cor: ${pedido.cor}",
              style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 12),
            Text(
              "Valor: R\$ ${pedido.valorTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 12),
            if (pedido.observacoes.isNotEmpty)
              Text(
                "Obs: ${pedido.observacoes}",
                style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
              ),
          ],
        ),
      ),
    );
  }
}