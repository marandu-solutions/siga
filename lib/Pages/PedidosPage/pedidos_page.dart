import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../Model/pedidos.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final List<Pedido> pedidos = [
    Pedido(
      id: 1001,
      numeroPedido: "1001",
      nomeCliente: "João Silva",
      telefoneCliente: "84999999999",
      servico: "Camiseta Personalizada",
      quantidade: 10,
      tamanho: "M",
      tipoMalha: "Algodão",
      cor: "Azul",
      observacoes: "",
      valorTotal: 250.00,
      dataPedido: DateTime(2025, 4, 1, 12, 30),
      estado: EstadoPedido.emAberto,
    ),
    Pedido(
      id: 1002,
      numeroPedido: "1002",
      nomeCliente: "Maria Souza",
      telefoneCliente: "84988888888",
      servico: "Camiseta Básica",
      quantidade: 5,
      tamanho: "G",
      tipoMalha: "Poliéster",
      cor: "Branca",
      observacoes: "Entrega urgente",
      valorTotal: 150.00,
      dataPedido: DateTime(2025, 4, 2, 14, 10),
      estado: EstadoPedido.emAndamento,
    ),
    // ... mais pedidos
  ];

  final Map<EstadoPedido, Color> coresColunas = {
    EstadoPedido.emAberto: Colors.orange.shade700,
    EstadoPedido.emAndamento: Colors.blue.shade700,
    EstadoPedido.finalizado: Colors.green.shade700,
    EstadoPedido.cancelado: Colors.red.shade700,
    EstadoPedido.entregaRetirada: Colors.purple.shade700,
  };

  @override
  Widget build(BuildContext context) {
    final Map<EstadoPedido, List<Pedido>> pedidosPorEstado = {
      for (var estado in EstadoPedido.values)
        estado: pedidos
            .where((p) => p.estado == estado)
            .toList()
          ..sort((a, b) => a.dataPedido.compareTo(b.dataPedido))
    };

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: EstadoPedido.values.map((estado) {
            final pedidosEstado = pedidosPorEstado[estado]!;
            final corFundo = coresColunas[estado]!;

            return Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: corFundo.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estado.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pedidosEstado.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidosEstado[index];
                        final duration = DateTime.now().difference(pedido.dataPedido);
                        final minutos = duration.inMinutes;

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(LucideIcons.clock4, size: 14),
                                          const SizedBox(width: 4),
                                          Text("${minutos}min", style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text("Cliente: ${pedido.nomeCliente}", style: const TextStyle(color: Colors.black),),
                                Text("Serviço: ${pedido.servico}", style: const TextStyle(color: Colors.black),),
                                Text("Qtd: ${pedido.quantidade} | Tamanho: ${pedido.tamanho}", style: const TextStyle(color: Colors.black),),
                                Text("Malha: ${pedido.tipoMalha} | Cor: ${pedido.cor}", style: const TextStyle(color: Colors.black),),
                                Text("Valor: R\$ ${pedido.valorTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.black),),
                                if (pedido.observacoes.isNotEmpty)
                                  Text("Obs: ${pedido.observacoes}", style: const TextStyle(color: Colors.black),),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
