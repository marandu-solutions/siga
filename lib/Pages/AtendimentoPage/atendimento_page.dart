import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:siga/Model/atendimento.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:siga/Pages/AtendimentoPage/Components/chat_page.dart';
import 'package:siga/Pages/AtendimentoPage/Components/contato_card.dart';
import 'package:siga/Service/atendimento_service.dart';
import 'package:siga/Service/auth_service.dart';

// O seu enum original.
enum EstadoAtendimento {
  emAberto,
  emAndamento,
  finalizado;

  String get label {
    switch (this) {
      case EstadoAtendimento.emAberto:
        return 'Em Aberto';
      case EstadoAtendimento.emAndamento:
        return 'Em Andamento';
      case EstadoAtendimento.finalizado:
        return 'Finalizado';
    }
  }

  static EstadoAtendimento fromString(String value) {
    return values.firstWhere((e) => e.label == value, orElse: () => emAberto);
  }
}

class AtendimentoPage extends StatefulWidget {
  const AtendimentoPage({super.key});

  @override
  State<AtendimentoPage> createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  // --- ESTADO LOCAL DA UI ---
  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE AÇÕES ATUALIZADA ---
  Future<void> _showNovoClienteDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final nomeController = TextEditingController();
    final telefoneController = TextEditingController();
    final fotoController = TextEditingController();

    // ✅ Acessamos os serviços necessários para a ação
    final atendimentoService = context.read<AtendimentoService>();
    final authService = context.read<AuthService>();
    final empresaId = authService.empresaAtual?.id;

    if (empresaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Empresa não identificada.')));
      return;
    }

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: cs.surfaceVariant.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Atendimento'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Aplicando o estilo e a cor do texto
              TextField(
                controller: nomeController,
                style: TextStyle(color: cs.onSurface),
                decoration: inputDecoration.copyWith(labelText: 'Nome do Cliente'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: telefoneController,
                style: TextStyle(color: cs.onSurface),
                decoration: inputDecoration.copyWith(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fotoController,
                style: TextStyle(color: cs.onSurface),
                decoration: inputDecoration.copyWith(labelText: 'URL da Foto (opcional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nome = nomeController.text.trim();
              final telefone = telefoneController.text.trim();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);

              if (nome.isNotEmpty && telefone.isNotEmpty) {
                final novoAtendimento = Atendimento(
                  id: '',
                  empresaId: empresaId,
                  nomeCliente: nome,
                  telefoneCliente: telefone,
                  fotoUrl: fotoController.text.trim().isNotEmpty ? fotoController.text.trim() : null,
                  status: EstadoAtendimento.emAberto.label,
                  updatedAt: Timestamp.now(),
                );

                try {
                  await atendimentoService.adicionarAtendimento(novoAtendimento);
                  scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Atendimento criado com sucesso!')));
                  navigator.pop();
                } catch(e) {
                  scaffoldMessenger.showSnackBar(SnackBar(content: Text('Falha ao criar atendimento: $e')));
                }
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  Future<void> _atualizarEstado(Atendimento atendimento, String novoEstado) async {
    final authService = context.read<AuthService>();
    final atendimentoService = context.read<AtendimentoService>();
    final funcionario = authService.funcionarioLogado;

    if(funcionario == null) return;
    
    final funcionarioAudit = {'uid': funcionario.uid, 'nome': funcionario.nome};

    try {
      await atendimentoService.atualizarEstadoAtendimento(
        atendimentoId: atendimento.id,
        novoEstado: novoEstado,
        funcionarioQueAtualizou: funcionarioAudit,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao mover card: $e")));
      }
    }
  }

  Color _getStatusColor(String statusLabel) {
    final estado = EstadoAtendimento.fromString(statusLabel);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (estado) {
      case EstadoAtendimento.emAberto: return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      case EstadoAtendimento.emAndamento: return isDark ? Colors.amber.shade300 : Colors.amber.shade800;
      case EstadoAtendimento.finalizado: return isDark ? Colors.green.shade400 : Colors.green.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final atendimentoService = context.read<AtendimentoService>();
    final empresaId = authService.empresaAtual?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimentos'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            // 1. BARRA DE FERRAMENTAS DEDICADA E CORRIGIDA
            _buildControls(),
            const SizedBox(height: 16),
            Expanded(
              child: empresaId == null
                  ? const Center(child: Text("Carregando..."))
                  : StreamBuilder<List<Atendimento>>(
                stream: atendimentoService.getAtendimentosDaEmpresaStream(empresaId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erro: ${snapshot.error}"));
                  }

                  final todosAtendimentos = snapshot.data ?? [];
                  final searchQuery = _searchController.text.toLowerCase();
                  final filteredList = todosAtendimentos.where((atendimento) {
                    final searchMatch = searchQuery.isEmpty ||
                        atendimento.nomeCliente.toLowerCase().contains(searchQuery) ||
                        atendimento.telefoneCliente.contains(searchQuery);
                    final filterMatch = _statusFilter == null || atendimento.status == _statusFilter;
                    return searchMatch && filterMatch;
                  }).toList();

                  return _buildBody(filteredList);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo Atendimento',
        child: const Icon(Icons.add),
        onPressed: () => _showNovoClienteDialog(context),
      ),
    );
  }

  // --- WIDGETS DE UI ---

  Widget _buildControls() {
    final theme = Theme.of(context);

    // Estilo que será usado pelos campos de controle
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // 2. Usando WRAP para um layout que quebra a linha e evita overflow
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Campo de busca
          SizedBox(
            width: 350, // Uma largura base para o campo de busca
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: inputDecoration.copyWith(
                hintText: 'Pesquisar por cliente ou telefone...',
                prefixIcon: const Icon(LucideIcons.search),
              ),
            ),
          ),

          // Filtro de Status
          SizedBox(
            width: 200, // Largura base para o filtro
            child: DropdownButtonFormField<String?>(
              value: _statusFilter,
              decoration: inputDecoration.copyWith(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...EstadoAtendimento.values.map((e) => DropdownMenuItem(value: e.label, child: Text(e.label))),
              ],
              onChanged: (v) => setState(() => _statusFilter = v),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBody(List<Atendimento> atendimentos) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (atendimentos.isEmpty) {
      return const Center(child: Text('Nenhum atendimento encontrado.'));
    }

    // A lógica de qual view mostrar permanece a mesma
    return isMobile
        ? _buildMobileList(atendimentos)
        : _buildDesktopKanban(atendimentos);
  }

  Widget _buildMobileList(List<Atendimento> atendimentos) {
    atendimentos.sort((a, b) => EstadoAtendimento.fromString(a.status).index.compareTo(EstadoAtendimento.fromString(b.status).index));

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: atendimentos.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        final atendimento = atendimentos[index];
        return _AtendimentoTile(
          atendimento: atendimento,
          onStatusChanged: (novoEstado) => _atualizarEstado(atendimento, novoEstado),
        );
      },
    );
  }

  Widget _buildDesktopKanban(List<Atendimento> atendimentos) {
    final estados = EstadoAtendimento.values.map((e) => e.label).toList();
    final cols = { for (var estadoLabel in estados) estadoLabel: atendimentos.where((a) => a.status == estadoLabel).toList() };

    return Listener(
      onPointerSignal: (sig) {
        if (sig is PointerScrollEvent) {
          _scrollController.jumpTo((_scrollController.offset + sig.scrollDelta.dy).clamp(_scrollController.position.minScrollExtent, _scrollController.position.maxScrollExtent));
        }
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cols.entries.map((e) => _buildColumn(e.key, e.value)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(String estadoLabel, List<Atendimento> items) {
    final theme = Theme.of(context);
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: _getStatusColor(estadoLabel), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(estadoLabel, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
              Text('${items.length}', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: DragTarget<Atendimento>(
              onWillAcceptWithDetails: (details) => details.data.status != estadoLabel,
              onAcceptWithDetails: (details) => _atualizarEstado(details.data, estadoLabel),
              builder: (context, cand, rej) => Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: cand.isNotEmpty ? theme.colorScheme.primary : Colors.transparent, width: 2)),
                child: items.isEmpty
                    ? Center(child: Text("Arraste um card para cá", style: theme.textTheme.bodySmall))
                    : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _buildDraggable(items[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggable(Atendimento a) {
    return Draggable<Atendimento>(
      data: a,
      feedback: Material(color: Colors.transparent, child: Opacity(opacity: 0.85, child: SizedBox(width: 280, child: ContatoCard(
        nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', status: a.status,
        onEstadoChanged: (novo) {},
      )))),
      childWhenDragging: Opacity(opacity: 0.4, child: ContatoCard(
        nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', status: a.status,
        onEstadoChanged: (novo) => _atualizarEstado(a, novo),
      )),
      child: ContatoCard(
        nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', status: a.status,
        onEstadoChanged: (novo) => _atualizarEstado(a, novo),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPage(
          nome: a.nomeCliente,
          numero: a.telefoneCliente,
          fotoUrl: a.fotoUrl ?? '',
        ))),
      ),
    );
  }
}

class _AtendimentoTile extends StatelessWidget {
  final Atendimento atendimento;
  final ValueChanged<String> onStatusChanged;

  const _AtendimentoTile({
    required this.atendimento,
    required this.onStatusChanged,
  });

  Color _getStatusColor(BuildContext context, String statusLabel) {
    final estado = EstadoAtendimento.fromString(statusLabel);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (estado) {
      case EstadoAtendimento.emAberto: return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      case EstadoAtendimento.emAndamento: return isDark ? Colors.amber.shade300 : Colors.amber.shade800;
      case EstadoAtendimento.finalizado: return isDark ? Colors.green.shade400 : Colors.green.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context, atendimento.status);
    final bool hasImage = atendimento.fotoUrl != null && atendimento.fotoUrl!.isNotEmpty;

    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(
        nome: atendimento.nomeCliente,
        numero: atendimento.telefoneCliente,
        fotoUrl: atendimento.fotoUrl ?? '',
      ))),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: hasImage ? NetworkImage(atendimento.fotoUrl!) : null,
        onBackgroundImageError: hasImage ? (_, __) {} : null,
        child: !hasImage ? const Icon(Icons.person, size: 30) : null,
      ),
      title: Text(atendimento.nomeCliente, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: const Text('Toque para ver a conversa...', style: TextStyle(overflow: TextOverflow.ellipsis)),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: statusColor),
        tooltip: 'Mudar status',
        onSelected: onStatusChanged,
        itemBuilder: (BuildContext context) => EstadoAtendimento.values.map((estado) => PopupMenuItem<String>(value: estado.label, child: Text(estado.label))).toList(),
      ),
    );
  }
}
