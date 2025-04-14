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

    return Container(
      color: const Color(0xFF1C1C2E),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gestão de Pedidos",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // Barra de pesquisa e filtro
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Pesquisar por número ou cliente...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(LucideIcons.search, color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF2A2A40),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<EstadoPedido?>(
                    value: filtroEstado,
                    dropdownColor: const Color(0xFF2A2A40),
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
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
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tabela de pedidos
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white.withOpacity(0.1)),
                      dataRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white.withOpacity(0.03)),
                      columns: const [
                        DataColumn(label: Text("N°Pedido", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Cliente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Serviço", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Quantidade", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Valor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Estado", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Ações", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ],
                      rows: pedidosFiltrados.map((pedido) {
                        return DataRow(cells: [
                          DataCell(Text(pedido.numeroPedido, style: const TextStyle(color: Colors.white))),
                          DataCell(Text(pedido.nomeCliente, style: const TextStyle(color: Colors.white))),
                          DataCell(Text(pedido.servico, style: const TextStyle(color: Colors.white))),
                          DataCell(Text(pedido.quantidade.toString(), style: const TextStyle(color: Colors.white))),
                          DataCell(Text("R\$ ${pedido.valorTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white))),
                          DataCell(
                            DropdownButtonHideUnderline(
                              child: DropdownButton<EstadoPedido>(
                                value: pedido.estado,
                                dropdownColor: const Color(0xFF2A2A40),
                                iconEnabledColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
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
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.edit, color: Colors.blueAccent),
                                  onPressed: () {
                                    // ação de edição
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                                  onPressed: () {
                                    // ação de exclusão
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
