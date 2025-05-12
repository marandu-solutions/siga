import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../Model/pedidos.dart';
import '../../Service/pedidos_service.dart';
import 'Components/add_pedido.dart';
import 'Components/pedido_details_page.dart';
import 'Components/tabela.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  bool _isKanbanView = false;
  final ScrollController _kanbanScrollController = ScrollController();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  EstadoPedido? _statusFilter;
  final PedidoService pedidosService = PedidoService();
  List<Pedido> _pedidos = []; // Lista local de pedidos

  Map<EstadoPedido, Color> _getCorColuna(BuildContext context) =>
      (Theme.of(context).brightness == Brightness.dark
          ? <EstadoPedido, Color>{
        EstadoPedido.emAberto: const Color(0xFF7016BD),
        EstadoPedido.emAndamento: const Color(0xFFC5960D),
        EstadoPedido.entregaRetirada: const Color(0xFFB13D10),
        EstadoPedido.finalizado: const Color(0xFF059E05),
        EstadoPedido.cancelado: const Color(0xFF9E051C),
      }
          : <EstadoPedido, Color>{
        EstadoPedido.emAberto: Colors.purple.shade500,
        EstadoPedido.emAndamento: Colors.amber.shade600,
        EstadoPedido.entregaRetirada: Colors.orange.shade700,
        EstadoPedido.finalizado: Colors.green.shade800,
        EstadoPedido.cancelado: Colors.red.shade800,
      });

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _kanbanScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return FutureBuilder<List<Pedido>>(
      future: pedidosService.getPedidos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar pedidos: ${snapshot.error}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }
        // Atualiza a lista local apenas na primeira carga
        if (_pedidos.isEmpty) {
          _pedidos = snapshot.data ?? [];
        }
        var displayed = _pedidos;

        if (isMobile) {
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            displayed = displayed.where((p) => p.nomeCliente.toLowerCase().contains(q)).toList();
          }
          if (_statusFilter != null) {
            displayed = displayed.where((p) => p.estado == _statusFilter).toList();
          }
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 1,
            title: isMobile && _isSearching
                ? TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar pedidos...',
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.search,
            )
                : Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'Pedidos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            actions: [
              if (isMobile) ...[
                IconButton(
                  icon: Icon(_isSearching ? LucideIcons.x : LucideIcons.search),
                  onPressed: () => setState(() {
                    if (_isSearching) _searchController.clear();
                    _isSearching = !_isSearching;
                  }),
                ),
                DropdownButton<EstadoPedido?>(
                  value: _statusFilter,
                  hint: const Icon(LucideIcons.filter),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<EstadoPedido?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    for (var st in EstadoPedido.values)
                      DropdownMenuItem<EstadoPedido?>(
                        value: st,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getCorColuna(context)[st]?.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            st.label,
                            style: TextStyle(
                              color: _getCorColuna(context)[st],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(LucideIcons.search),
                  onPressed: () => setState(() => _isSearching = !_isSearching),
                ),
                const SizedBox(width: 8),
                ViewToggleButton(
                  theme: theme,
                  isKanbanView: _isKanbanView,
                  onToggle: (v) => setState(() => _isKanbanView = v),
                ),
                const SizedBox(width: 16),
              ],
            ],
          ),
          body: displayed.isEmpty
              ? Center(
            child: Text(
              isMobile ? 'Nenhum pedido encontrado' : 'Nenhum pedido cadastrado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
              : LayoutBuilder(builder: (ctx, cons) {
            if (isMobile) {
              return _buildMobilePedidosList(displayed);
            }
            return _isKanbanView
                ? _buildDesktopKanban(displayed)
                : _buildTabela(displayed);
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddPedidoDialog(
                  onAdd: (novoPedido) {
                    setState(() {
                      _pedidos.add(novoPedido);
                    });
                  },
                ),
              );
            },
            child: const Icon(LucideIcons.plus),
          ),
        );
      },
    );
  }

  void _onPedidoEstadoChanged(Pedido p) async {
    // Atualiza o estado no servidor
    await pedidosService.atualizarEstadoPedido(p.id, p.estado);
    // Atualiza a lista local sem recarregar a tela
    final index = _pedidos.indexWhere((pedido) => pedido.id == p.id);
    if (index != -1) {
      setState(() {
        _pedidos[index] = p;
      });
    }
  }

  Widget _buildMobilePedidosList(List<Pedido> pedidos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      itemCount: pedidos.length,
      itemBuilder: (ctx, i) {
        final pedido = pedidos[i];
        return _buildPedidoCard(pedido, draggable: false);
      },
    );
  }

  Widget _buildDesktopKanban(List<Pedido> pedidos) {
    final porEstado = {
      for (var st in EstadoPedido.values)
        st: pedidos.where((p) => p.estado == st).toList()
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Listener(
        onPointerSignal: (ps) {
          if (ps is PointerScrollEvent) {
            final newOff = _kanbanScrollController.offset + ps.scrollDelta.dy;
            final clamped = newOff.clamp(
              _kanbanScrollController.position.minScrollExtent,
              _kanbanScrollController.position.maxScrollExtent,
            );
            _kanbanScrollController.jumpTo(clamped);
          }
        },
        child: SingleChildScrollView(
          controller: _kanbanScrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: EstadoPedido.values.map((st) {
              final lista = porEstado[st]!;
              final cor = _getCorColuna(context)[st]!;
              return DragTarget<Pedido>(
                onWillAccept: (p) => p != null && p.estado != st,
                onAccept: (p) => _onPedidoEstadoChanged(p.copyWith(estado: st)),
                builder: (c, cand, rej) => Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: cand.isNotEmpty
                        ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          st.label,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: lista.isEmpty
                            ? const Center(child: Text('Nenhum pedido'))
                            : ListView.builder(
                          itemCount: lista.length,
                          itemBuilder: (_, j) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildPedidoCard(lista[j], draggable: true),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabela(List<Pedido> pedidos) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Tabela(
        pedidos: pedidos,
        onEstadoChanged: (p) => _onPedidoEstadoChanged(p),
        onDelete: (p) async {
          try {
            // Stub: Não faz nada, apenas exibe mensagem
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Remover pedido não disponível no momento')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro: $e')),
            );
          }
        },
        onEdit: (p) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: p)),
        ),
      ),
    );
  }

  Widget _buildPedidoCard(Pedido pedido, {required bool draggable}) {
    final theme = Theme.of(context);
    final card = Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openDetails(pedido),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pedido #${pedido.id.substring(0, 8)}'),
              const SizedBox(height: 4),
              Text('Cliente: ${pedido.nomeCliente}'),
              Text('Serviço: ${pedido.servico}'),
              const SizedBox(height: 8),
              if (!draggable) ...[
                DropdownButton<EstadoPedido>(
                  value: pedido.estado,
                  underline: const SizedBox(),
                  items: EstadoPedido.values
                      .map((st) => DropdownMenuItem(
                    value: st,
                    child: Text(st.label),
                  ))
                      .toList(),
                  onChanged: (novo) {
                    if (novo != null) {
                      _onPedidoEstadoChanged(pedido.copyWith(estado: novo));
                    }
                  },
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}'),
                  _buildActionButtons(pedido),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (draggable) {
      return Draggable<Pedido>(
        data: pedido,
        feedback: Material(color: Colors.transparent, child: card),
        childWhenDragging: Opacity(opacity: 0.3, child: card),
        child: card,
      );
    }
    return card;
  }

  Widget _buildActionButtons(Pedido pedido) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: Icon(LucideIcons.edit, color: theme.iconTheme.color),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: pedido)),
          ),
        ),
        IconButton(
          icon: Icon(LucideIcons.trash, color: theme.iconTheme.color),
          onPressed: () async {
            try {
              // Stub: Não faz nada, apenas exibe mensagem
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Remover pedido não disponível no momento')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro: $e')),
              );
            }
          },
        ),
      ],
    );
  }

  void _openDetails(Pedido p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: p)),
    );
  }
}

class ViewToggleButton extends StatelessWidget {
  final ThemeData theme;
  final bool isKanbanView;
  final ValueChanged<bool> onToggle;

  const ViewToggleButton({
    super.key,
    required this.theme,
    required this.isKanbanView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: [!isKanbanView, isKanbanView],
      onPressed: (index) => onToggle(index == 1),
      borderRadius: BorderRadius.circular(8),
      selectedColor: theme.colorScheme.primary,
      fillColor: theme.colorScheme.primary.withOpacity(0.1),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Icon(LucideIcons.table),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Icon(LucideIcons.columns),
        ),
      ],
    );
  }
}