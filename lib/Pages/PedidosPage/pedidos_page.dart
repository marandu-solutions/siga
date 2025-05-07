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

  Map<EstadoPedido, Color> _getCorColuna(BuildContext context) => {
    EstadoPedido.emAberto: Colors.purple.shade300,
    EstadoPedido.emAndamento: Colors.amber.shade400,
    EstadoPedido.entregaRetirada: Colors.orange.shade500,
    EstadoPedido.finalizado: Colors.green.shade600,
    EstadoPedido.cancelado: Colors.red.shade600,
  };

  @override
  void dispose() {
    _kanbanScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pedidosModel = context.watch<PedidoModel>();
    final pedidos = pedidosModel.pedidos;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth; // sem sidebar

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 1,
        title: Padding(
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
          if (availableWidth >= 600) ...[
            ViewToggleButton(
              theme: theme,
              isKanbanView: _isKanbanView,
              onToggle: (v) => setState(() => _isKanbanView = v),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: pedidos.isEmpty
          ? Center(
        child: Text(
          'Nenhum pedido cadastrado',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          if (availableWidth < 600) {
            return _buildMobilePedidosList(pedidos);
          }
          return _isKanbanView
              ? _buildDesktopKanban(pedidos)
              : _buildTabela(pedidos);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final novoPedido = Pedido(
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
          context.read<PedidoModel>().adicionarPedido(novoPedido);
        },
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _onPedidoEstadoChanged(Pedido pedidoAtualizado) {
    context.read<PedidoModel>().atualizarPedido(
      pedidoAtualizado.id,
      pedidoAtualizado,
    );
  }

  Widget _buildMobilePedidosList(List<Pedido> pedidos) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          return _buildPedidoCard(pedido, draggable: false);
        },
      ),
    );
  }

  Widget _buildDesktopKanban(List<Pedido> pedidos) {
    final pedidosPorEstado = {
      for (var estado in EstadoPedido.values)
        estado: pedidos.where((p) => p.estado == estado).toList(),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Listener(
        onPointerSignal: (ps) {
          if (ps is PointerScrollEvent) {
            final delta = ps.scrollDelta.dy;
            final newOffset = _kanbanScrollController.offset + delta;
            final clamped = newOffset.clamp(
              _kanbanScrollController.position.minScrollExtent,
              _kanbanScrollController.position.maxScrollExtent,
            );
            _kanbanScrollController.jumpTo(clamped);
          }
        },
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: SingleChildScrollView(
            controller: _kanbanScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: EstadoPedido.values.map((estado) {
                final lista = pedidosPorEstado[estado]!;
                final corFundo = _getCorColuna(context)[estado]!;

                return DragTarget<Pedido>(
                  onWillAccept: (p) => p != null && p.estado != estado,
                  onAccept: (p) {
                    _onPedidoEstadoChanged(p.copyWith(estado: estado));
                  },
                  builder: (context, candidate, rejected) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: corFundo.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: candidate.isNotEmpty
                            ? Border.all(
                          color:
                          Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow,
                            blurRadius: 6,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              estado.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: lista.isEmpty
                                ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Nenhum pedido'),
                              ),
                            )
                                : ListView.builder(
                              itemCount: lista.length,
                              itemBuilder: (ctx, i) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: _buildPedidoCard(
                                    lista[i], draggable: true),
                              ),
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
      ),
    );
  }

  Widget _buildTabela(List<Pedido> pedidos) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Tabela(
        pedidos: pedidos,
        onEstadoChanged: (p) =>
            context.read<PedidoModel>().atualizarPedido(p.id, p),
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
    final cardContent = Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: InkWell(
        onTap: () => _openDetails(pedido),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedido #${pedido.numeroPedido}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text('Cliente: ${pedido.nomeCliente}',
                  style: theme.textTheme.bodySmall),
              Text('Serviço: ${pedido.servico}',
                  style: theme.textTheme.bodySmall),
              Text('Status: ${pedido.estado.label}',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall),
                  _buildActionButtons(pedido),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!draggable) return cardContent;

    return Draggable<Pedido>(
      data: pedido,
      feedback: Material(
        color: Colors.transparent,
        elevation: 6,
        child: Opacity(opacity: 0.85, child: cardContent),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: cardContent),
      child: cardContent,
    );
  }

  Widget _buildActionButtons(Pedido pedido) {
    final theme = Theme.of(context);
    final model = context.read<PedidoModel>();
    return Row(
      children: [
        IconButton(
          icon: Icon(LucideIcons.edit, size: 18, color: theme.iconTheme.color),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PedidoDetailsPage(pedido: pedido)),
          ),
        ),
        IconButton(
          icon:
          Icon(LucideIcons.trash, size: 18, color: theme.iconTheme.color),
          onPressed: () {
            model.removerPedido(pedido.id);
          },
        ),
      ],
    );
  }

  void _openDetails(Pedido pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: pedido)),
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
