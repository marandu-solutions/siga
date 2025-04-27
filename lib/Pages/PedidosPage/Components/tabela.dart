import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../Model/pedidos.dart';
import 'pedido_details_page.dart';

class Tabela extends StatefulWidget {
  final List<Pedido> pedidos;
  final Function(Pedido) onEstadoChanged;
  final Function(Pedido) onDelete;
  final Function(Pedido) onEdit;

  const Tabela({
    super.key,
    required this.pedidos,
    required this.onEstadoChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<Tabela> createState() => _TabelaState();
}

class _TabelaState extends State<Tabela> {
  final TextEditingController _searchController = TextEditingController();
  EstadoPedido? _filtroEstado;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final pedidosFiltrados = widget.pedidos.where((pedido) {
      final textoBusca = _searchController.text.toLowerCase();
      final combinaBusca = pedido.numeroPedido.contains(textoBusca) ||
          pedido.nomeCliente.toLowerCase().contains(textoBusca);
      final combinaEstado = _filtroEstado == null || pedido.estado == _filtroEstado;
      return combinaBusca && combinaEstado;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: "Título da gestão de pedidos",
            child: Text(
              "Gestão de Pedidos",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Pesquisar por número ou cliente...",
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                    prefixIcon: Icon(LucideIcons.search, color: colorScheme.onSurface),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 15),
              DropdownButton<EstadoPedido?>(
                value: _filtroEstado,
                hint: Text(
                  "Filtrar por estado",
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onChanged: (EstadoPedido? newValue) {
                  setState(() {
                    _filtroEstado = newValue;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      "Todos",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                  ...EstadoPedido.values.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(
                        estado.label,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                ],
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface),
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 40, // Subtract padding (20 + 20)
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 16,
                      headingRowColor: MaterialStateColor.resolveWith(
                            (states) => colorScheme.primaryContainer,
                      ),
                      dataRowColor: MaterialStateColor.resolveWith(
                            (states) => colorScheme.surface,
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            "Pedido",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Cliente",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Serviço",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Quantidade",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Valor",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Data",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Estado",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Ações",
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                      rows: pedidosFiltrados.map((pedido) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Semantics(
                                label: "Número do pedido ${pedido.numeroPedido}",
                                child: Text(
                                  pedido.numeroPedido,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Semantics(
                                label: "Cliente ${pedido.nomeCliente}",
                                child: Text(
                                  pedido.nomeCliente,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Semantics(
                                label: "Serviço ${pedido.servico}",
                                child: Text(
                                  pedido.servico,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Semantics(
                                label: "Quantidade ${pedido.quantidade}",
                                child: Text(
                                  pedido.quantidade.toString(),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Semantics(
                                label: "Valor R\$ ${pedido.valorTotal.toStringAsFixed(2)}",
                                child: Text(
                                  "R\$ ${pedido.valorTotal.toStringAsFixed(2)}",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Semantics(
                                label: "Data do pedido ${DateFormat('dd/MM/yyyy').format(pedido.dataPedido)}",
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(pedido.dataPedido),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Semantics(
                                label: "Estado do pedido ${pedido.estado.label}",
                                child: DropdownButton<EstadoPedido>(
                                  value: pedido.estado,
                                  isDense: true,
                                  onChanged: (EstadoPedido? newValue) {
                                    if (newValue != null) {
                                      widget.onEstadoChanged(pedido.copyWith(estado: newValue));
                                    }
                                  },
                                  items: EstadoPedido.values.map((estado) {
                                    return DropdownMenuItem(
                                      value: estado,
                                      child: Text(
                                        estado.label,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  dropdownColor: colorScheme.surface,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
                                ),
                              ),
                            ),
                            DataCell(
                              Semantics(
                                label: "Ações para o pedido ${pedido.numeroPedido}",
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(LucideIcons.eye, color: colorScheme.primary),
                                      tooltip: "Ver detalhes",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PedidoDetailsPage(pedido: pedido),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(LucideIcons.edit, color: colorScheme.secondary),
                                      tooltip: "Editar",
                                      onPressed: () {
                                        widget.onEdit(pedido);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(LucideIcons.trash2, color: colorScheme.error),
                                      tooltip: "Excluir",
                                      onPressed: () async {
                                        final bool? confirmar = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              "Confirmar exclusão",
                                              style: textTheme.titleMedium?.copyWith(
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            content: Text(
                                              "Deseja excluir o pedido #${pedido.numeroPedido}?",
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            backgroundColor: colorScheme.surface,
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: Text(
                                                  "Cancelar",
                                                  style: TextStyle(color: colorScheme.primary),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: Text(
                                                  "Excluir",
                                                  style: TextStyle(color: colorScheme.error),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmar == true) {
                                          widget.onDelete(pedido);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Pedido #${pedido.numeroPedido} excluído",
                                                style: TextStyle(color: colorScheme.onSurface),
                                              ),
                                              backgroundColor: colorScheme.surface,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}