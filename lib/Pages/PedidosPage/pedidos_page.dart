import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:siga/Model/pedidos.dart';
import 'package:siga/Service/auth_service.dart';
import 'package:siga/Service/pedidos_service.dart';


// Os componentes de UI que você criou podem ser importados normalmente.
// Supondo que eles existam e recebam os parâmetros corretos.
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
  // Estado local da UI: controla a aparência e os filtros da tela.
  bool _isKanbanView = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter; // Filtro por status (string)

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get isMobile => MediaQuery.of(context).size.width < 700;

  // --- MÉTODOS DE AÇÃO (CRUD) ATUALIZADOS ---

  Future<void> _adicionarPedido(Pedido pedido) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PedidoService>().adicionarPedido(pedido);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Pedido #${pedido.numeroPedido} adicionado com sucesso!')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erro ao adicionar pedido: $e')),
      );
    }
  }

  Future<void> _deletarPedido(Pedido pedido) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PedidoService>().deletarPedido(pedido.id);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Pedido #${pedido.numeroPedido} excluído.')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erro ao excluir pedido: $e')),
      );
    }
  }

  Future<void> _atualizarEstadoPedido(Pedido pedido, String novoEstado) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authService = context.read<AuthService>();
    final funcionario = authService.funcionarioLogado;
    if (funcionario == null) return;

    final funcionarioAudit = {'uid': funcionario.uid, 'nome': funcionario.nome};

    try {
      await context.read<PedidoService>().atualizarStatusPedido(
        pedidoId: pedido.id,
        novoStatus: novoEstado,
        funcionarioQueAtualizou: funcionarioAudit,
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erro ao atualizar estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoService = context.read<PedidoService>();
    final authService = context.watch<AuthService>();
    final empresaId = authService.empresaAtual?.id;
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
                autofocus: true,
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
            DropdownButton<String?>(
              value: _statusFilter,
              hint: const Icon(LucideIcons.filter, color: Colors.white),
              underline: const SizedBox(),
              iconEnabledColor: Colors.white,
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                for (var st in EstadoPedido.values)
                  DropdownMenuItem(
                    value: st.label,
                    child: Text(st.label),
                  ),
              ],
              onChanged: (v) => setState(() => _statusFilter = v),
            ),
          ] else ...[
            if (_isSearching)
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar por cliente ou número...',
                    border: InputBorder.none,
                    suffixIcon: Icon(LucideIcons.search)
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(LucideIcons.search),
                onPressed: () => setState(() => _isSearching = true),
              ),
            if(_isSearching)
              IconButton(
                icon: const Icon(LucideIcons.xCircle),
                onPressed: () => setState(() {
                  _searchController.clear();
                  _isSearching = false;
                }),
              ),
            const SizedBox(width: 8),
            ViewToggleButton(
              theme: Theme.of(context),
              isKanbanView: _isKanbanView,
              onToggle: (v) => setState(() => _isKanbanView = v),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: empresaId == null
          ? const Center(child: Text("Carregando dados da empresa..."))
          : StreamBuilder<List<Pedido>>(
              stream: pedidoService.getPedidosDaEmpresaStream(empresaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erro ao carregar pedidos: ${snapshot.error}"));
                }
                
                List<Pedido> todosOsPedidos = snapshot.data ?? [];
                final displayed = todosOsPedidos.where((p) {
                  final statusMatch = _statusFilter == null || p.status == _statusFilter;
                  final searchMatch = _searchQuery.isEmpty ||
                      p.numeroPedido.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (p.cliente['nome'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                  return statusMatch && searchMatch;
                }).toList();
                
                return _buildBody(displayed, corColuna);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddPedidoDialog(),
        ),
        tooltip: 'Adicionar Pedido',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(List<Pedido> pedidos, Map<String, Color> corColuna) {
    if (isMobile) {
      return _buildMobileList(pedidos);
    }
    
    if (pedidos.isEmpty) {
      return const Center(child: Text('Nenhum pedido encontrado com os filtros aplicados.'));
    }

    return _isKanbanView
        ? Kanban(
            pedidos: pedidos,
            corColuna: corColuna,
            onPedidoEstadoChanged: (p, novoEstado) => _atualizarEstadoPedido(p, novoEstado),
            onDelete: (p) => _deletarPedido(p),
            onTapDetails: (p) => Navigator.push(
              context, MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: p)),
            ),
          )
        : Tabela(
            pedidos: pedidos,
            onEstadoChanged: (p, novoEstado) => _atualizarEstadoPedido(p, novoEstado),
            onDelete: (p) => _deletarPedido(p),
            onEdit: (p) => Navigator.push(
              context, MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: p)),
            ),
          );
  }

  Widget _buildMobileList(List<Pedido> pedidos) {
    if (pedidos.isEmpty) {
      return const Center(child: Text('Nenhum pedido encontrado.'));
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

  Map<String, Color> _mapCorColuna(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ✅ Chaves agora são Strings para corresponder ao modelo
    return {
      EstadoPedido.emAberto.label: isDark ? const Color(0xFF7016BD) : Colors.purple.shade500,
      EstadoPedido.emAndamento.label: isDark ? const Color(0xFFC5960D) : Colors.amber.shade600,
      EstadoPedido.entregaRetirada.label: isDark ? const Color(0xFFB13D10) : Colors.orange.shade700,
      EstadoPedido.finalizado.label: isDark ? const Color(0xFF059E05) : Colors.green.shade800,
      EstadoPedido.cancelado.label: isDark ? const Color(0xFF9E051C) : Colors.red.shade800,
    };
  }
}

// --- CLASSES AUXILIARES DE UI (Sem alterações na lógica) ---

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
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _ToggleIcon(
            icon: LucideIcons.layoutGrid,
            label: 'Kanban',
            selected: isKanbanView,
            onTap: () => onToggle(true),
          ),
          _ToggleIcon(
            icon: LucideIcons.table,
            label: 'Tabela',
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
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}