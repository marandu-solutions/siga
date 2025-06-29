import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:siga/Model/pedidos.dart';
import 'package:siga/Service/auth_service.dart';
import 'package:siga/Service/pedidos_service.dart';

// Importando todos os componentes que a página utiliza
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
  // Serviços e Estado da UI
  final PedidoService _pedidoService = PedidoService();
  bool _isKanbanView = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter;

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

  // A sua lógica de CRUD e comunicação com os serviços foi 100% preservada.
  Future<void> _adicionarPedido(Pedido pedido) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PedidoService>().adicionarPedido(pedido);
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Pedido #${pedido.numeroPedido} adicionado!')));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao adicionar pedido: $e')));
    }
  }

  Future<void> _deletarPedido(Pedido pedido) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PedidoService>().deletarPedido(pedido.id);
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Pedido #${pedido.numeroPedido} excluído.')));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao excluir pedido: $e')));
    }
  }

  Future<void> _atualizarEstadoPedido(Pedido pedido, String novoEstado) async {
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar estado: $e')));
    }
  }

  Future<void> _navegarParaDetalhes(Pedido pedido) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => PedidoDetailsPage(pedido: pedido)));
  }

  // --- BUILD METHOD PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final empresaId = authService.empresaAtual?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Pedidos'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            _buildControls(context),
            const SizedBox(height: 16),
            Expanded(
              child: empresaId == null
                  ? const Center(child: Text("Carregando dados da empresa..."))
                  : StreamBuilder<List<Pedido>>(
                stream: _pedidoService.getPedidosDaEmpresaStream(empresaId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erro ao carregar pedidos: ${snapshot.error}"));
                  }

                  final todosOsPedidos = snapshot.data ?? [];
                  final displayed = todosOsPedidos.where((p) {
                    final statusMatch = _statusFilter == null || p.status == _statusFilter;
                    final searchMatch = _searchQuery.isEmpty ||
                        p.numeroPedido.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (p.cliente['nome'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                    return statusMatch && searchMatch;
                  }).toList();

                  return _buildBody(displayed);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_) => const AddPedidoDialog()),
        tooltip: 'Adicionar Pedido',
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO DA UI ---

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 755;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
    );

    // CORREÇÃO: Usando Wrap para um layout flexível que evita overflow.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Campo de busca
          SizedBox(
            width: isMobile ? double.infinity : 350,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: inputDecoration.copyWith(hintText: 'Pesquisar por nº ou cliente...', prefixIcon: const Icon(LucideIcons.search)),
            ),
          ),

          // Controles de filtro e visualização
          Row(
            mainAxisSize: MainAxisSize.min, // Encolhe a Row para o tamanho dos filhos
            children: [
              // Filtro de Status
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String?>(
                  value: _statusFilter,
                  decoration: inputDecoration.copyWith(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...EstadoPedido.values.map((e) => DropdownMenuItem(value: e.label, child: Text(e.label))),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ),
              const SizedBox(width: 16),
              // Botão de Visualização
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, icon: Icon(LucideIcons.layoutGrid), label: Text("Kanban")),
                  ButtonSegment(value: false, icon: Icon(LucideIcons.table2), label: Text("Tabela")),
                ],
                selected: {_isKanbanView},
                onSelectionChanged: (selection) => setState(() => _isKanbanView = selection.first),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<Pedido> pedidos) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (pedidos.isEmpty) {
      return _buildEmptyState();
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: pedidos.length,
        itemBuilder: (_, i) => PedidoCard(
          pedido: pedidos[i],
          onTapDetails: () => _navegarParaDetalhes(pedidos[i]),
          onDelete: () => _deletarPedido(pedidos[i]),
          onStatusChanged: (novoEstado) => _atualizarEstadoPedido(pedidos[i], novoEstado),
        ),
      );
    }

    final corColuna = {
      for (var e in EstadoPedido.values)
        e.label: _mapCorColuna(context)[e] ?? Colors.grey
    };

    return _isKanbanView
        ? Kanban(
      pedidos: pedidos, corColuna: corColuna,
      onPedidoEstadoChanged: _atualizarEstadoPedido,
      onDelete: _deletarPedido,
      onTapDetails: _navegarParaDetalhes,
    )
        : Tabela(
      pedidos: pedidos,
      onEstadoChanged: _atualizarEstadoPedido,
      onDelete: _deletarPedido,
      onEdit: _navegarParaDetalhes,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.folderSearch, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Nenhum pedido encontrado.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tente ajustar os filtros ou adicione um novo pedido.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Map<EstadoPedido, Color> _mapCorColuna(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return {
      EstadoPedido.emAberto: isDark ? Colors.purple.shade300 : Colors.purple.shade500,
      EstadoPedido.emAndamento: isDark ? Colors.amber.shade300 : Colors.amber.shade600,
      EstadoPedido.entregaRetirada: isDark ? Colors.orange.shade400 : Colors.orange.shade700,
      EstadoPedido.finalizado: isDark ? Colors.green.shade400 : Colors.green.shade800,
      EstadoPedido.cancelado: isDark ? Colors.red.shade400 : Colors.red.shade800,
    };
  }
}
