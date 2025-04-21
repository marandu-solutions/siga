import 'package:flutter/material.dart';
import '../../Model/pedidos.dart';
import 'Components/pedidos_card.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  List<Pedido> pedidos = [
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
  ];

  final Map<EstadoPedido, Color> corColuna = {
    EstadoPedido.emAberto: Colors.grey.shade900, // Cinza escuro
    EstadoPedido.emAndamento: Colors.blueGrey.shade900, // Azul cinza escuro
    EstadoPedido.entregaRetirada: Colors.purple.shade900, // Roxo escuro
    EstadoPedido.finalizado: Colors.green.shade900, // Verde escuro
    EstadoPedido.cancelado: Colors.red.shade900, // Vermelho escuro
  };

  @override
  Widget build(BuildContext context) {
    final pedidosPorEstado = {
      for (var estado in EstadoPedido.values)
        estado: pedidos
            .where((p) => p.estado == estado)
            .toList()
          ..sort((a, b) => a.dataPedido.compareTo(b.dataPedido)),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: Colors.grey.shade800, // Cor escura para a appBar
        automaticallyImplyLeading: false, // Remover a setinha de voltar
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: EstadoPedido.values.map((estado) {
              final pedidosEstado = pedidosPorEstado[estado]!;
              final corFundo = corColuna[estado]!;

              return DragTarget<Pedido>(
                onWillAccept: (pedido) => pedido?.estado != estado,
                onAccept: (pedido) {
                  setState(() {
                    final index = pedidos.indexWhere((p) => p.id == pedido.id);
                    if (index != -1) {
                      pedidos[index] = pedido.copyWith(estado: estado);
                    }
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: corFundo.withOpacity(0.85), // Opacidade leve para o fundo
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estado.label,
                          style: const TextStyle(
                            color: Colors.white, // Texto claro para o tema escuro
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: pedidosEstado.isEmpty
                              ? const Center(
                            child: Text(
                              "Nenhum pedido",
                              style: TextStyle(color: Colors.white70), // Texto claro
                            ),
                          )
                              : ListView.builder(
                            itemCount: pedidosEstado.length,
                            itemBuilder: (context, index) {
                              final pedido = pedidosEstado[index];
                              return Draggable<Pedido>(
                                data: pedido,
                                feedback: Opacity(
                                  opacity: 0.7,
                                  child: PedidoCard(pedido: pedido),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: PedidoCard(pedido: pedido),
                                ),
                                child: PedidoCard(pedido: pedido),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
