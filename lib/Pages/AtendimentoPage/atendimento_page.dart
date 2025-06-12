import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'components/chat_page.dart';
import 'components/contato_card.dart'; // Reutilizando seu ContatoCard original para o Kanban
import '../../../Model/atendimento.dart';
import 'dart:ui';

class AtendimentoPage extends StatefulWidget {
  const AtendimentoPage({Key? key}) : super(key: key);

  @override
  State<AtendimentoPage> createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  // --- ESTADO PARA KANBAN (DESKTOP) ---
  EstadoAtendimento? colunaDragSource;
  final Map<EstadoAtendimento, bool> isSearching = {};
  final Map<EstadoAtendimento, TextEditingController> searchControllers = {};
  final Map<EstadoAtendimento, Color> headerColor = {
    EstadoAtendimento.emAberto: Colors.purple.shade500,
    EstadoAtendimento.emAndamento: Colors.amber.shade600,
    EstadoAtendimento.finalizado: Colors.green.shade700,
  };
  final ScrollController _scrollController = ScrollController();

  // --- ESTADO PARA LISTA (MOBILE) ---
  final _mobileSearchController = TextEditingController();
  bool _isMobileSearching = false;
  EstadoAtendimento? _mobileFilter;


  @override
  void initState() {
    super.initState();
    // Setup para Kanban
    for (var estado in EstadoAtendimento.values) {
      isSearching[estado] = false;
      searchControllers[estado] = TextEditingController();
    }
    // Setup para Mobile
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

  // --- Função para adicionar novo cliente (agora funcional) ---
  void _showNovoClienteDialog(BuildContext context) {
    final nomeController = TextEditingController();
    final telefoneController = TextEditingController();
    final fotoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Cliente')),
              TextField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              ),
              TextField(controller: fotoController, decoration: const InputDecoration(labelText: 'URL da Foto (opcional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final nome = nomeController.text.trim();
              final telefone = telefoneController.text.trim();
              final foto = fotoController.text.trim();
              if (nome.isNotEmpty && telefone.isNotEmpty) {
                final novo = Atendimento(
                  id: UniqueKey().toString(),
                  nomeCliente: nome,
                  telefoneCliente: telefone,
                  fotoUrl: foto.isNotEmpty ? foto : null,
                  estado: EstadoAtendimento.emAberto,
                );
                context.read<AtendimentoModel>().adicionar(novo);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  // Função para obter a cor do status para a lista mobile.
  Color _getStatusColor(BuildContext context, EstadoAtendimento estado) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (estado) {
      case EstadoAtendimento.emAberto: return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      case EstadoAtendimento.emAndamento: return isDark ? Colors.amber.shade300 : Colors.amber.shade800;
      case EstadoAtendimento.finalizado: return isDark ? Colors.green.shade400 : Colors.green.shade800;
      default: return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: isMobile
          ? _buildMobileList() // A nova lista para mobile
          : _buildDesktopKanban(), // O seu Kanban original para desktop
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo Cliente',
        child: const Icon(Icons.add),
        onPressed: () => _showNovoClienteDialog(context),
      ),
    );
  }

  // =======================================================================
  // =================== CONTEÚDO MOBILE (LISTA WHATSAPP) ==================
  // =======================================================================
  Widget _buildMobileList() {
    final theme = Theme.of(context);
    final atendimentos = context.watch<AtendimentoModel>().atendimentos;

    final filteredList = atendimentos.where((atendimento) {
      final search = _mobileSearchController.text.toLowerCase();
      final filter = _mobileFilter;
      final matchSearch = atendimento.nomeCliente.toLowerCase().contains(search) || atendimento.telefoneCliente.contains(search);
      final matchFilter = filter == null || atendimento.estado == filter;
      return matchSearch && matchFilter;
    }).toList();
    filteredList.sort((a, b) => a.estado.index.compareTo(b.estado.index));

    return Column(
      children: [
        AppBar(
          title: _isMobileSearching
              ? TextField(
            controller: _mobileSearchController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Pesquisar...', border: InputBorder.none),
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
              PopupMenuButton<EstadoAtendimento?>(
                icon: const Icon(Icons.filter_list),
                onSelected: (novoFiltro) => setState(() => _mobileFilter = novoFiltro),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: null, child: Text('Todos os Status')),
                  ...EstadoAtendimento.values.map((estado) => PopupMenuItem(value: estado, child: Text(estado.label))),
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
            separatorBuilder: (context, index) => Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final atendimento = filteredList[index];
              return _AtendimentoTile(
                atendimento: atendimento,
                statusColor: _getStatusColor(context, atendimento.estado),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(
                  nome: atendimento.nomeCliente,
                  numero: atendimento.telefoneCliente,
                  fotoUrl: atendimento.fotoUrl ?? '',
                ))),
              );
            },
          ),
        ),
      ],
    );
  }

  // =======================================================================
  // ===================== CONTEÚDO DESKTOP (KANBAN) =======================
  // =======================================================================

  // SEU CÓDIGO KANBAN ORIGINAL, PRATICAMENTE INTACTO

  Widget _buildDesktopKanban() {
    final atendimentos = context.watch<AtendimentoModel>().atendimentos;
    final cols = {
      for (var estado in EstadoAtendimento.values)
        estado: atendimentos.where((a) => a.estado == estado).toList(),
    };
    final totalWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 48.0;
    final colCount = cols.length;
    final colWidth = (totalWidth - horizontalPadding) / colCount;

    return Listener(
      onPointerSignal: (sig) {
        if (sig is PointerScrollEvent) {
          final off = _scrollController.offset + sig.scrollDelta.dy;
          _scrollController.jumpTo(off.clamp(_scrollController.position.minScrollExtent, _scrollController.position.maxScrollExtent));
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
            children: cols.entries.map((e) {
              return Container(
                width: colWidth,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildColumn(e.key, e.value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(EstadoAtendimento estado, List<Atendimento> items) {
    final searching = isSearching[estado]!;
    final text = searchControllers[estado]!.text.toLowerCase();
    final filtered = items.where((a) => a.nomeCliente.toLowerCase().contains(text) || a.telefoneCliente.contains(text)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(color: headerColor[estado]!.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: searching
                    ? _buildSearchField(estado)
                    : Text(estado.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headerColor[estado])),
              ),
              if (!searching)
                IconButton(icon: Icon(Icons.search, color: headerColor[estado]), onPressed: () => setState(() => isSearching[estado] = true)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: DragTarget<Atendimento>(
            onWillAccept: (_) => true,
            onAccept: (a) {
              if (colunaDragSource != null) {
                final updated = a.copyWith(estado: estado);
                context.read<AtendimentoModel>().atualizar(a.id, updated);
              }
            },
            builder: (context, cand, rej) => Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(8),
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final a = filtered[i];
                  return _buildDraggable(a, estado);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(EstadoAtendimento estado) {
    return TextField(
      controller: searchControllers[estado],
      decoration: InputDecoration(
        hintText: 'Pesquisar...',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => setState(() { isSearching[estado] = false; searchControllers[estado]!.clear(); }),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDraggable(Atendimento a, EstadoAtendimento origem) {
    return Draggable<Atendimento>(
      data: a,
      onDragStarted: () => colunaDragSource = origem,
      feedback: Material(color: Colors.transparent, child: Opacity(opacity: 0.85, child: SizedBox(width: 220, child: ContatoCard(
        nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', estado: a.estado,
        onEstadoChanged: (novo) => context.read<AtendimentoModel>().atualizar(a.id, a.copyWith(estado: novo)),
      )))),
      childWhenDragging: Opacity(opacity: 0.4, child: ContatoCard(
        nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', estado: a.estado,
        onEstadoChanged: (novo) => context.read<AtendimentoModel>().atualizar(a.id, a.copyWith(estado: novo)),
      )),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPage(
          nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '',
        ))),
        child: ContatoCard(
          nome: a.nomeCliente, numero: a.telefoneCliente, fotoUrl: a.fotoUrl ?? '', estado: a.estado,
          onEstadoChanged: (novo) => context.read<AtendimentoModel>().atualizar(a.id, a.copyWith(estado: novo)),
        ),
      ),
    );
  }
}


// Widget dedicado para o item da lista mobile, no estilo do WhatsApp.
class _AtendimentoTile extends StatelessWidget {
  final Atendimento atendimento;
  final Color statusColor;
  final VoidCallback onTap;

  const _AtendimentoTile({
    required this.atendimento,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasImage = atendimento.fotoUrl != null && atendimento.fotoUrl!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // CÓDIGO CORRIGIDO ABAIXO
            CircleAvatar(
              radius: 28,
              // A propriedade 'backgroundImage' só recebe a imagem se 'hasImage' for verdadeiro.
              backgroundImage: hasImage ? NetworkImage(atendimento.fotoUrl!) : null,
              // A propriedade 'onBackgroundImageError' agora só é definida se 'hasImage' for verdadeiro.
              // Isso satisfaz a regra do Flutter e corrige o crash.
              onBackgroundImageError: hasImage ? (_, __) {} : null,
              // O ícone de fallback só aparece se 'hasImage' for falso.
              child: !hasImage ? const Icon(Icons.person, size: 30) : null,
            ),
            // O resto do widget continua o mesmo
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    atendimento.nomeCliente,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque para ver a conversa...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '15:32',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '1',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

