// lib/Pages/PedidosPage/pedidos_page.dart

import 'dart:ui'; // Para PointerDeviceKind e PointerScrollEvent
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../Model/pedidos.dart';
import 'Components/pedido_details_page.dart';
import 'Components/tabela.dart';
import '../../Model/pedidos_model.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  bool _isKanbanView = false;
  final ScrollController _kanbanScrollController = ScrollController();

  // Mobile-only: search + status filter
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  EstadoPedido? _statusFilter;

  Map<EstadoPedido, Color> _getCorColuna(BuildContext context) =>
      (Theme.of(context).brightness == Brightness.dark
      // Mapa para Tema Escuro
          ? <EstadoPedido, Color>{
        EstadoPedido.emAberto: const Color(0xFF7016BD),    // neon purple
        EstadoPedido.emAndamento: const Color(0xFFC5960D), // neon amber
        EstadoPedido.entregaRetirada: const Color(0xFFB13D10), // neon orange
        EstadoPedido.finalizado: const Color(0xFF059E05),  // neon green
        EstadoPedido.cancelado: const Color(0xFF9E051C),   // neon red
      }
      // Mapa para Tema Claro
          : <EstadoPedido, Color>{
        EstadoPedido.emAberto: Colors.purple.shade500,
        EstadoPedido.emAndamento: Colors.amber.shade600,
        EstadoPedido.entregaRetirada: Colors.orange.shade700,
        EstadoPedido.finalizado: Colors.green.shade800,
        EstadoPedido.cancelado: Colors.red.shade800,
      }
      );

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
    final pedidosModel = context.watch<PedidoModel>();
    final pedidos = pedidosModel.pedidos;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    // Filtra por busca e status (mobile apenas)
    var displayed = pedidos;
    if (isMobile) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        displayed = displayed.where((p) =>
        p.numeroPedido.toLowerCase().contains(q) ||
            p.nomeCliente.toLowerCase().contains(q)
        ).toList();
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
            // search toggle
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
              underline: SizedBox(),
              items: [
                DropdownMenuItem<EstadoPedido?>(
                  value: null,
                  child: const Text('Todos'),
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
            // desktop: toggle view + search icon
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
          final novo = Pedido(
            id: DateTime.now().millisecondsSinceEpoch,
            numeroPedido: DateTime.now().millisecondsSinceEpoch.toString(),
            nomeCliente: 'Cliente Teste',
            telefoneCliente: '77900000000',
            servico: 'Serviço de Teste',
            quantidade: 1,
            tamanho: 'M',
            tipoMalha: 'Algodão',
            cor: 'Preto',
            observacoes: 'Gerado para teste CRUD',
            valorTotal: 99.9,
            dataPedido: DateTime.now(),
            estado: EstadoPedido.emAberto,
          );
          pedidosModel.adicionarPedido(novo);
        },
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _onPedidoEstadoChanged(Pedido p) {
    context.read<PedidoModel>().atualizarPedido(p.id, p);
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
                            child:
                            _buildPedidoCard(lista[j], draggable: true),
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
        onDelete: (p) => context.read<PedidoModel>().removerPedido(p.id),
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openDetails(pedido),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pedido #${pedido.numeroPedido}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Cliente: ${pedido.nomeCliente}',
                  style: theme.textTheme.bodySmall),
              Text('Serviço: ${pedido.servico}',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              if (!draggable) ...[
                // Dropdown para alterar status
                DropdownButton<EstadoPedido>(
                  value: pedido.estado,
                  underline: SizedBox(),
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
          icon:
          Icon(LucideIcons.edit, color: theme.iconTheme.color),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PedidoDetailsPage(pedido: pedido)),
          ),
        ),
        IconButton(
          icon:
          Icon(LucideIcons.trash, color: theme.iconTheme.color),
          onPressed: () =>
              context.read<PedidoModel>().removerPedido(pedido.id),
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
  final bool isKanbanView;
  final ValueChanged<bool> onToggle;
  final ThemeData theme;

  const ViewToggleButton({
    super.key,
    required this.isKanbanView,
    required this.onToggle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _ToggleIcon(
            icon: LucideIcons.layoutGrid,
            selected: isKanbanView,
            onTap: () => onToggle(true),
          ),
          _ToggleIcon(
            icon: LucideIcons.table,
            selected: !isKanbanView,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleIcon({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 20,
          color: selected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
