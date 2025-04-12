import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../Model/pedidos.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final TextEditingController _searchController = TextEditingController();
  EstadoPedido? filtroEstado;

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
      dataPedido: DateTime(2025, 4, 1),
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
      dataPedido: DateTime(2025, 4, 2),
      estado: EstadoPedido.emAndamento,
    ),
  ];

  final List<EstadoPedido> estadosPedido = EstadoPedido.values;

  @override
  Widget build(BuildContext context) {
    final pedidosFiltrados = pedidos.where((pedido) {
      final textoBusca = _searchController.text.toLowerCase();
      final combinaBusca = pedido.numeroPedido.contains(textoBusca) ||
          pedido.nomeCliente.toLowerCase().contains(textoBusca);
      final combinaEstado = filtroEstado == null || pedido.estado == filtroEstado;
      return combinaBusca && combinaEstado;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gestão de Pedidos",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Barra de pesquisa e filtro
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Pesquisar por número ou cliente...",
                    prefixIcon: const Icon(LucideIcons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 15),

              // Dropdown de estado
              DropdownButton<EstadoPedido?>(
                value: filtroEstado,
                onChanged: (EstadoPedido? newValue) {
                  setState(() {
                    filtroEstado = newValue;
                  });
                },
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Todos"),
                  ),
                  ...estadosPedido.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(estado.label),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tabela
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView(
                children: [
                  DataTable(
                    columnSpacing: 12,
                    headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blue.shade100,
                    ),
                    columns: const [
                      DataColumn(label: Text("Pedido", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Serviço", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Quantidade", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Valor", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Ações", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: pedidosFiltrados.map((pedido) {
                      return DataRow(cells: [
                        DataCell(Text(pedido.numeroPedido)),
                        DataCell(Text(pedido.nomeCliente)),
                        DataCell(Text(pedido.servico)),
                        DataCell(Text(pedido.quantidade.toString())),
                        DataCell(Text("R\$ ${pedido.valorTotal.toStringAsFixed(2)}")),
                        DataCell(
                          DropdownButton<EstadoPedido>(
                            value: pedido.estado,
                            onChanged: (EstadoPedido? newValue) {
                              setState(() {
                                pedido.estado = newValue!;
                              });
                            },
                            items: estadosPedido.map((estado) {
                              return DropdownMenuItem(
                                value: estado,
                                child: Text(estado.label),
                              );
                            }).toList(),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.edit, color: Colors.blueAccent),
                                onPressed: () {
                                  // Implementar ação de edição
                                },
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                                onPressed: () {
                                  // Implementar ação de exclusão
                                },
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
