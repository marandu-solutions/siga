import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:siga/Model/atendimento.dart';


import 'package:siga/Pages/AtendimentoPage/Components/chat_page.dart';
import 'package:siga/Pages/AtendimentoPage/Components/contato_card.dart';
import 'package:siga/Service/atendimento_service.dart';
import 'package:siga/Service/auth_service.dart';

// Este enum ainda é útil para a lógica da UI, como ordenação de colunas e filtros.
enum EstadoAtendimento {
  emAberto,
  emAndamento,
  finalizado;

  String get label {
    switch (this) {
      case EstadoAtendimento.emAberto: return 'Em Aberto';
      case EstadoAtendimento.emAndamento: return 'Em Andamento';
      case EstadoAtendimento.finalizado: return 'Finalizado';
    }
  }

  static EstadoAtendimento fromString(String value) {
    switch (value) {
      case 'Em Aberto': return EstadoAtendimento.emAberto;
      case 'Em Andamento': return EstadoAtendimento.emAndamento;
      case 'Finalizado': return EstadoAtendimento.finalizado;
      default: return EstadoAtendimento.emAberto;
    }
  }
}

class AtendimentoPage extends StatefulWidget {
  const AtendimentoPage({super.key});

  @override
  State<AtendimentoPage> createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  // --- ESTADO LOCAL DA UI (SEM ALTERAÇÕES) ---
  final Map<String, bool> isSearching = {};
  final Map<String, TextEditingController> searchControllers = {};
  final Map<String, Color> headerColor = {
    EstadoAtendimento.emAberto.label: Colors.purple.shade500,
    EstadoAtendimento.emAndamento.label: Colors.amber.shade600,
    EstadoAtendimento.finalizado.label: Colors.green.shade700,
  };
  final ScrollController _scrollController = ScrollController();
  final _mobileSearchController = TextEditingController();
  bool _isMobileSearching = false;
  String? _mobileFilter;

  @override
  void initState() {
    super.initState();
    for (var estado in EstadoAtendimento.values) {
      final label = estado.label;
      isSearching[label] = false;
      searchControllers[label] = TextEditingController();
    }
    _mobileSearchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (var ctrl in searchControllers.values) {
      ctrl.dispose();
    }
    _mobileSearchController.dispose();
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
    // O método 'adicionarAtendimento' precisa ser criado no AtendimentoService
    // final atendimentoService = context.read<AtendimentoService>(); 
    final authService = context.read<AuthService>();
    final empresaId = authService.empresaAtual?.id;

    if (empresaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Empresa não identificada.')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Atendimento'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeController, decoration: InputDecoration(labelText: 'Nome do Cliente')),
              const SizedBox(height: 16),
              TextField(controller: telefoneController, decoration: InputDecoration(labelText: 'Telefone'), keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)]),
              const SizedBox(height: 16),
              TextField(controller: fotoController, decoration: InputDecoration(labelText: 'URL da Foto (opcional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nome = nomeController.text.trim();
              final telefone = telefoneController.text.trim();
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
                // await atendimentoService.adicionarAtendimento(novoAtendimento);
                Navigator.of(ctx).pop();
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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    
    final authService = context.watch<AuthService>();
    final atendimentoService = context.read<AtendimentoService>();
    final empresaId = authService.empresaAtual?.id;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: empresaId == null
          ? const Center(child: Text("Carregando dados da empresa..."))
          : StreamBuilder<List<Atendimento>>(
              stream: atendimentoService.getAtendimentosDaEmpresaStream(empresaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erro ao carregar atendimentos: ${snapshot.error}"));
                }
                final todosAtendimentos = snapshot.data ?? [];

                return isMobile
                    ? _buildMobileList(todosAtendimentos)
                    : _buildDesktopKanban(todosAtendimentos);
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo Atendimento',
        child: const Icon(Icons.add),
        onPressed: () => _showNovoClienteDialog(context),
      ),
    );
  }

  // --- WIDGETS DE UI (com as devidas adaptações) ---

  Widget _buildMobileList(List<Atendimento> atendimentos) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final filteredList = atendimentos.where((atendimento) {
      final search = _mobileSearchController.text.toLowerCase();
      final filter = _mobileFilter;
      final matchSearch = atendimento.nomeCliente.toLowerCase().contains(search) || atendimento.telefoneCliente.contains(search);
      final matchFilter = filter == null || atendimento.status == filter;
      return matchSearch && matchFilter;
    }).toList();
    filteredList.sort((a, b) => EstadoAtendimento.fromString(a.status).index.compareTo(EstadoAtendimento.fromString(b.status).index));

    return Column(
      children: [
        AppBar(
          title: _isMobileSearching
              ? TextField(
                  controller: _mobileSearchController,
                  autofocus: true,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                      hintText: 'Pesquisar...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: cs.onSurfaceVariant)
                  ),
                )
              : const Text('Atendimentos'),
          actions: [
            IconButton(
              icon: Icon(_isMobileSearching ? Icons.close : Icons.search),
              onPressed: () => setState(() {
                _isMobileSearching = !_isMobileSearching;
                if (!_isMobileSearching) _mobileSearchController.clear();
              }),
            ),
            if (!_isMobileSearching)
              PopupMenuButton<String?>(
                icon: const Icon(Icons.filter_list),
                onSelected: (novoFiltro) => setState(() => _mobileFilter = novoFiltro),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: null, child: Text('Todos os Status')),
                  ...EstadoAtendimento.values.map((estado) => PopupMenuItem(value: estado.label, child: Text(estado.label))),
                ],
              ),
          ],
        ),
        Expanded(
          child: filteredList.isEmpty
              ? const Center(child: Text('Nenhum atendimento encontrado.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
                  itemBuilder: (context, index) {
                    final atendimento = filteredList[index];
                    return _AtendimentoTile(
                      atendimento: atendimento,
                      statusColor: _getStatusColor(context, atendimento.status),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(
                        nome: atendimento.nomeCliente,
                        numero: atendimento.telefoneCliente,
                        fotoUrl: atendimento.fotoUrl ?? '',
                      ))),
                      onStatusChanged: (novoEstado) => _atualizarEstado(atendimento, novoEstado),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDesktopKanban(List<Atendimento> atendimentos) {
    final estados = EstadoAtendimento.values.map((e) => e.label).toList();
    final cols = { for (var estadoLabel in estados) estadoLabel: atendimentos.where((a) => a.status == estadoLabel).toList() };
    final totalWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 48.0;
    final colCount = cols.length;
    final colWidth = (totalWidth - horizontalPadding) / colCount;

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
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cols.entries.map((e) => Container(width: colWidth, margin: const EdgeInsets.symmetric(horizontal: 12), child: _buildColumn(e.key, e.value))).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(String estadoLabel, List<Atendimento> items) {
    final searching = isSearching[estadoLabel]!;
    final text = searchControllers[estadoLabel]!.text.toLowerCase();
    final filtered = items.where((a) => a.nomeCliente.toLowerCase().contains(text) || a.telefoneCliente.contains(text)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(color: headerColor[estadoLabel]!.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(children: [
            Expanded(child: searching ? _buildSearchField(estadoLabel) : Text(estadoLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headerColor[estadoLabel]))),
            if (!searching) IconButton(icon: Icon(Icons.search, color: headerColor[estadoLabel]), onPressed: () => setState(() => isSearching[estadoLabel] = true)),
          ]),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: DragTarget<Atendimento>(
            onWillAcceptWithDetails: (details) => details.data.status != estadoLabel,
            onAcceptWithDetails: (details) => _atualizarEstado(details.data, estadoLabel),
            builder: (context, cand, rej) => Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12), border: Border.all(color: cand.isNotEmpty ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2)),
              padding: const EdgeInsets.all(8),
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _buildDraggable(filtered[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSearchField(String estadoLabel) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return TextField(
      controller: searchControllers[estadoLabel],
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: 'Pesquisar...',
        hintStyle: TextStyle(color: cs.onSurfaceVariant),
        filled: true,
        isDense: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        suffixIcon: IconButton(icon: Icon(Icons.close, color: cs.onSurfaceVariant, size: 20), onPressed: () => setState(() { isSearching[estadoLabel] = false; searchControllers[estadoLabel]!.clear(); })),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDraggable(Atendimento a) {
    return Draggable<Atendimento>(
      data: a,
      feedback: Material(color: Colors.transparent, child: Opacity(opacity: 0.85, child: SizedBox(width: 280, child: ContatoCard(
        nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', status: a.status,
        onEstadoChanged: (novo) {/* no-op no feedback */},
      )))),
      childWhenDragging: Opacity(opacity: 0.4, child: ContatoCard(
        nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', status: a.status,
        onEstadoChanged: (novo) => _atualizarEstado(a, novo),
      )),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPage(nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? ''))),
        child: ContatoCard(
          nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', status: a.status,
          onEstadoChanged: (novo) => _atualizarEstado(a, novo),
        ),
      ),
    );
  }
}

class _AtendimentoTile extends StatelessWidget {
  final Atendimento atendimento;
  final Color statusColor;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusChanged;

  const _AtendimentoTile({
    required this.atendimento,
    required this.statusColor,
    required this.onTap,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasImage = atendimento.fotoUrl != null && atendimento.fotoUrl!.isNotEmpty;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: hasImage ? NetworkImage(atendimento.fotoUrl!) : null,
        onBackgroundImageError: hasImage ? (_, __) {} : null,
        child: !hasImage ? const Icon(Icons.person, size: 30) : null,
      ),
      title: Text(
        atendimento.nomeCliente,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Toque para ver a conversa...',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: statusColor),
        tooltip: 'Mudar status',
        onSelected: onStatusChanged,
        itemBuilder: (BuildContext context) {
          return EstadoAtendimento.values.map((estado) {
            return PopupMenuItem<String>(
              value: estado.label,
              child: Text(estado.label),
            );
          }).toList();
        },
      ),
    );
  }
}