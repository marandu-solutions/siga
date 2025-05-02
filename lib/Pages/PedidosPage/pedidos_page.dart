// lib/Pages/pedidos_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../Model/pedidos.dart';
import 'Components/kanban.dart';
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

  Map<EstadoPedido, Color> _getCorColuna(BuildContext context) => {
    EstadoPedido.emAberto: Theme.of(context).colorScheme.primaryContainer,
    EstadoPedido.emAndamento: Colors.green.shade700,
    EstadoPedido.entregaRetirada: Colors.orange.shade600,
    EstadoPedido.finalizado: Colors.blueGrey.shade300,
    EstadoPedido.cancelado: Colors.red.shade600,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pedidosModel = context.watch<PedidoModel>();
    final pedidos = pedidosModel.pedidos;
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = 250.0;
    final availableWidth = screenWidth - sidebarWidth;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
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
        centerTitle: false,
        automaticallyImplyLeading: false,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (availableWidth < 600) {
            return _buildPedidosList(pedidos);
          }
          return _isKanbanView ? _buildKanban(pedidos) : _buildTabela(pedidos);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Exemplo de pedido de teste para validar CRUD
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

  Widget _buildPedidosList(List<Pedido> pedidos) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          return _buildPedidoCard(pedido);
        },
      ),
    );
  }

  Widget _buildPedidoCard(Pedido pedido) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: InkWell(
        onTap: () => _openDetails(pedido),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pedido #${pedido.numeroPedido}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  )),
              const SizedBox(height: 8),
              Text('Cliente: ${pedido.nomeCliente}', style: theme.textTheme.bodyMedium),
              Text('Serviço: ${pedido.servico}', style: theme.textTheme.bodyMedium),
              Text('Status: ${pedido.estado.label}', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium),
                  _buildActionButtons(pedido),
                ],
              ),
            ],
          ),
        ),
      ),
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
            MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: pedido)),
          ),
        ),
        IconButton(
          icon: Icon(LucideIcons.trash, size: 18, color: theme.iconTheme.color),
          onPressed: () {
            model.removerPedido(pedido.id);
          },
        ),
      ],
    );
  }

  Widget _buildTabela(List<Pedido> pedidos) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Tabela(
        pedidos: pedidos,
        onEstadoChanged: (p) => context.read<PedidoModel>().atualizarPedido(p.id, p),
        onDelete: (p) => context.read<PedidoModel>().removerPedido(p.id),
        onEdit: (p) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: p)),
        ),
      ),
    );
  }

  Widget _buildKanban(List<Pedido> pedidos) {
    return Kanban(
      pedidos: pedidos,
      corColuna: _getCorColuna(context),
      onPedidoEstadoChanged: (p) => context.read<PedidoModel>().atualizarPedido(p.id, p),
      onDelete: (p) => context.read<PedidoModel>().removerPedido(p.id),
      onTapDetails: _openDetails,
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
        color: theme.colorScheme.secondaryContainer,
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
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
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
          color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
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
