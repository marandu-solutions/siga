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
  final ScrollController _horizontalController = ScrollController();
  EstadoPedido? _filtroEstado;

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final pedidosFiltrados = widget.pedidos.where((p) {
      final busca = _searchController.text.toLowerCase();
      final okTexto = p.numeroPedido.contains(busca) ||
          p.nomeCliente.toLowerCase().contains(busca);
      final okEstado = _filtroEstado == null || p.estado == _filtroEstado;
      return okTexto && okEstado;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gestão de Pedidos",
            style: tt.headlineSmall
                ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Pesquisar por número ou cliente...",
                    prefixIcon: Icon(LucideIcons.search, color: cs.onSurface),
                    filled: true,
                    fillColor: cs.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<EstadoPedido?>(
                value: _filtroEstado,
                hint: Text("Filtrar por estado",
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text("Todos",
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                  ),
                  ...EstadoPedido.values.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.label,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                  )),
                ],
                onChanged: (v) => setState(() => _filtroEstado = v),
                dropdownColor: cs.surface,
                icon: Icon(Icons.arrow_drop_down, color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 40),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTableTheme(
                        data: DataTableThemeData(
                          headingRowColor: MaterialStateProperty.all(
                              cs.primaryContainer),
                          dataRowColor: MaterialStateProperty.all(cs.surface),
                          dividerThickness: 1.2,
                          headingTextStyle: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                          dataTextStyle:
                          tt.bodyMedium?.copyWith(color: cs.onSurface),
                          headingRowHeight: 56,
                          dataRowHeight: 56,
                        ),
                        child: DataTable(
                          columnSpacing: 24,
                          horizontalMargin: 12,
                          showBottomBorder: true,
                          columns: [
                            _buildColumn("Pedido"),
                            _buildColumn("Cliente"),
                            _buildColumn("Itens"),
                            _buildColumn("Quantidade"),
                            _buildColumn("Valor"),
                            _buildColumn("Data"),
                            _buildColumn("Estado"),
                            _buildColumn("Ações"),
                          ],
                          rows: pedidosFiltrados.map((pedido) {
                            // Calcular a quantidade total somando as quantidades dos itens
                            final quantidadeTotal = pedido.itens.fold<int>(
                              0,
                                  (sum, item) => sum + item.quantidade,
                            );

                            // Calcular o valor total somando os preços dos itens
                            final valorTotal = pedido.itens.fold<double>(
                              0.0,
                                  (sum, item) => sum + (item.preco * item.quantidade),
                            );

                            // Representação dos itens (ex.: "Hambúrguer e mais 2 itens")
                            final itensText = pedido.itens.isNotEmpty
                                ? pedido.itens.length == 1
                                ? pedido.itens[0].nome
                                : "${pedido.itens[0].nome} e mais ${pedido.itens.length - 1} item${pedido.itens.length > 2 ? 's' : ''}"
                                : "Nenhum item";

                            return DataRow(cells: [
                              _buildCell(pedido.numeroPedido, cs, tt,
                                  semantics:
                                  "Número do pedido ${pedido.numeroPedido}"),
                              _buildCell(pedido.nomeCliente, cs, tt,
                                  semantics: "Cliente ${pedido.nomeCliente}"),
                              _buildCell(itensText, cs, tt,
                                  semantics: "Itens $itensText"),
                              _buildCell(quantidadeTotal.toString(), cs, tt,
                                  semantics: "Quantidade $quantidadeTotal"),
                              _buildCell(
                                  "R\$ ${valorTotal.toStringAsFixed(2)}",
                                  cs,
                                  tt,
                                  semantics:
                                  "Valor R\$ ${valorTotal.toStringAsFixed(2)}"),
                              _buildCell(
                                  DateFormat('dd/MM/yyyy')
                                      .format(pedido.dataPedido),
                                  cs,
                                  tt,
                                  semantics:
                                  "Data do pedido ${DateFormat('dd/MM/yyyy').format(pedido.dataPedido)}"),
                              DataCell(
                                DropdownButton<EstadoPedido>(
                                  value: pedido.estado,
                                  isDense: true,
                                  underline: const SizedBox(),
                                  onChanged: (novo) {
                                    if (novo != null) {
                                      widget.onEstadoChanged(
                                          pedido.copyWith(estado: novo));
                                    }
                                  },
                                  items: EstadoPedido.values
                                      .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.label,
                                        style: tt.bodyMedium?.copyWith(
                                            color: cs.onSurface)),
                                  ))
                                      .toList(),
                                  dropdownColor: cs.surface,
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: cs.onSurface),
                                ),
                              ),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(LucideIcons.edit,
                                        color: cs.secondary),
                                    tooltip: "Editar",
                                    onPressed: () => widget.onEdit(pedido),
                                  ),
                                  IconButton(
                                    icon: Icon(LucideIcons.trash2,
                                        color: cs.error),
                                    tooltip: "Excluir",
                                    onPressed: () async {
                                      final confirma = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text("Confirmar exclusão",
                                              style: tt.titleMedium?.copyWith(
                                                  color: cs.onSurface)),
                                          content: Text(
                                            "Excluir pedido #${pedido.numeroPedido}?",
                                            style: tt.bodyMedium?.copyWith(
                                                color: cs.onSurface),
                                          ),
                                          backgroundColor: cs.surface,
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text("Cancelar",
                                                  style: TextStyle(
                                                      color: cs.primary)),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: Text("Excluir",
                                                  style: TextStyle(
                                                      color: cs.error)),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                          false;
                                      if (confirma) {
                                        widget.onDelete(pedido);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Pedido #${pedido.numeroPedido} excluído",
                                              style: tt.bodyMedium?.copyWith(
                                                  color: cs.onSurface),
                                            ),
                                            backgroundColor: cs.surface,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
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

  DataColumn _buildColumn(String label) => DataColumn(label: Text(label));

  DataCell _buildCell(String text, ColorScheme cs, TextTheme tt,
      {required String semantics}) =>
      DataCell(
        Semantics(
          label: semantics,
          child: Text(text),
        ),
      );
}