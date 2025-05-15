import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../Model/pedidos.dart';
import '../../Service/pedidos_service.dart';
import 'Components/add_pedido.dart';
import 'Components/pedido_details_page.dart';
import 'Components/kanban.dart';
import 'Components/pedidos_card.dart';
import 'Components/tabela.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final PedidoService _pedidoService = PedidoService();
  bool _isLoading = false;
  bool _isKanbanView = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  EstadoPedido? _statusFilter;

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final pedidos = context.watch<PedidoModel>().pedidos;
    final corColuna = _mapCorColuna(context);

    return Scaffold(
      appBar: AppBar(
        title: isMobile && _isSearching
            ? TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Pesquisar pedidos...',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
        )
            : const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Pedidos'),
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
                const DropdownMenuItem(value: null, child: Text('Todos')),
                for (var st in EstadoPedido.values)
                  DropdownMenuItem(
                    value: st,
                    child: Text(st.label),
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
              theme: Theme.of(context),
              isKanbanView: _isKanbanView,
              onToggle: (v) => setState(() => _isKanbanView = v),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchPedidos,
              tooltip: 'Atualizar',
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(pedidos, corColuna),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddPedidoDialog(onAdd: _adicionarPedido),
        ),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Pedido',
      ),
    );
  }

  Widget _buildBody(List<Pedido> pedidos, Map<EstadoPedido, Color> corColuna) {
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
      return _buildMobileList(displayed);
    }

    if (displayed.isEmpty) {
      return const Center(child: Text('Nenhum pedido encontrado'));
    }

    return _isKanbanView
        ? Kanban(
      pedidos: displayed,
      corColuna: corColuna,
      onPedidoEstadoChanged: (p) => _atualizarEstadoPedido(p, p.estado),
      onDelete: (p) => _deletarPedido(p),
      onTapDetails: (p) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: p)),
      ),
    )
        : Tabela(
      pedidos: displayed,
      onEstadoChanged: (p) => _atualizarEstadoPedido(p, p.estado),
      onDelete: (p) => _deletarPedido(p),
      onEdit: (p) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: p)),
      ),
    );
  }

  Widget _buildMobileList(List<Pedido> pedidos) {
    if (pedidos.isEmpty) {
      return const Center(child: Text('Nenhum pedido encontrado'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pedidos.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: PedidoCard(
          pedido: pedidos[i],
          onTapDetails: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: pedidos[i])),
          ),
          onDelete: () => _deletarPedido(pedidos[i]),
          onStatusChanged: (novoEstado) => _atualizarEstadoPedido(pedidos[i], novoEstado),
        ),
      ),
    );
  }

  Map<EstadoPedido, Color> _mapCorColuna(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? {
        EstadoPedido.emAberto: const Color(0xFF7016BD),
        EstadoPedido.emAndamento: const Color(0xFFC5960D),
        EstadoPedido.entregaRetirada: const Color(0xFFB13D10),
        EstadoPedido.finalizado: const Color(0xFF059E05),
        EstadoPedido.cancelado: const Color(0xFF9E051C),
      }
          : {
        EstadoPedido.emAberto: Colors.purple.shade500,
        EstadoPedido.emAndamento: Colors.amber.shade600,
        EstadoPedido.entregaRetirada: Colors.orange.shade700,
        EstadoPedido.finalizado: Colors.green.shade800,
        EstadoPedido.cancelado: Colors.red.shade800,
      };

  Future<void> _fetchPedidos() async {
    setState(() => _isLoading = true);
    try {
      final pedidos = await _pedidoService.getPedidos();
      if (mounted) {
        final model = context.read<PedidoModel>();
        model.limparPedidos();
        for (var p in pedidos) model.adicionarPedido(p);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pedidos: \$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _adicionarPedido(Pedido pedido) async {
    try {
      final criado = await _pedidoService.adicionarPedido(pedido);
      if (mounted) {
        context.read<PedidoModel>().adicionarPedido(criado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido #\${criado.numeroPedido} adicionado')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar pedido: \$e')),
      );
    }
  }

  Future<void> _editarPedido(Pedido pedido) async {
    try {
      await _pedidoService.editarPedido(pedido);
      if (mounted) {
        context.read<PedidoModel>().atualizarPedido(pedido.id, pedido);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido #\${pedido.numeroPedido} atualizado')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao editar pedido: \$e')),
      );
    }
  }

  Future<void> _deletarPedido(Pedido pedido) async {
    try {
      await _pedidoService.deletarPedido(pedido.id);
      if (mounted) {
        context.read<PedidoModel>().removerPedido(pedido.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido #\${pedido.numeroPedido} excluído')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir pedido: \$e')),
      );
    }
  }

  Future<void> _atualizarEstadoPedido(Pedido pedido, EstadoPedido novoEstado) async {
    try {
      await _pedidoService.atualizarEstadoPedido(pedido.id, novoEstado);
      if (mounted) {
        final updated = pedido.copyWith(estado: novoEstado);
        context.read<PedidoModel>().atualizarPedido(pedido.id, updated);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar estado: \$e')),
      );
    }
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