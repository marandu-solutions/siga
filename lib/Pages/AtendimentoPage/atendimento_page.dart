// lib/Pages/AtendimentoPage/atendimento_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para inputFormatters
import 'package:provider/provider.dart';
import 'package:siga/Pages/AtendimentoPage/Components/contato_card.dart';
import 'package:siga/Pages/AtendimentoPage/Components/chat_page.dart';
import 'package:siga/Model/atendimento.dart';
import 'dart:ui'; // Para PointerDeviceKind

class AtendimentoPage extends StatefulWidget {
  const AtendimentoPage({Key? key}) : super(key: key);

  @override
  State<AtendimentoPage> createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  EstadoAtendimento? colunaDragSource;
  final Map<EstadoAtendimento, bool> isSearching = {};
  final Map<EstadoAtendimento, TextEditingController> searchControllers = {};
  final Map<EstadoAtendimento, Color> headerColor = {
    EstadoAtendimento.emAberto: Colors.purple.shade500,
    EstadoAtendimento.emAndamento: Colors.amber.shade600,
    EstadoAtendimento.finalizado: Colors.green.shade700,
  };

  // Mobile search e filtro
  bool isMobileSearching = false;
  late TextEditingController mobileSearchController;
  EstadoAtendimento? mobileFilter;

  // Scroll horizontal para desktop
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    for (var estado in EstadoAtendimento.values) {
      isSearching[estado] = false;
      searchControllers[estado] = TextEditingController();
    }
    mobileSearchController = TextEditingController();
  }

  @override
  void dispose() {
    for (var ctrl in searchControllers.values) {
      ctrl.dispose();
    }
    mobileSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    final atendimentos = context.watch<AtendimentoModel>().atendimentos;
    final cardsPorColuna = {
      for (var estado in EstadoAtendimento.values)
        estado: atendimentos.where((a) => a.estado == estado).toList(),
    };

    return Scaffold(
      backgroundColor: cs.background,
      appBar: isMobile
          ? AppBar(
        title: const Text('Atendimentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() {
              isMobileSearching = !isMobileSearching;
              if (!isMobileSearching) mobileSearchController.clear();
            }),
          ),
          PopupMenuButton<EstadoAtendimento?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (novo) => setState(() => mobileFilter = novo),
            itemBuilder: (_) => [
              const PopupMenuItem<EstadoAtendimento?>(
                value: null,
                child: Text('Todos'),
              ),
              ...EstadoAtendimento.values.map(
                    (e) => PopupMenuItem(
                  value: e,
                  child: Text(e.label),
                ),
              ),
            ],
          ),
        ],
      )
          : null,
      body: isMobile
          ? _buildMobileContent(cs, atendimentos)
          : _buildDesktopKanban(cs, cardsPorColuna),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo Cliente',
        child: const Icon(Icons.add),
        onPressed: () => _showNovoClienteDialog(context),
      ),
    );
  }

  void _showNovoClienteDialog(BuildContext context) {
    final nomeController = TextEditingController();
    final telefoneController = TextEditingController();
    final fotoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Cliente'),
            ),
            TextField(
              controller: telefoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11), // até 11 dígitos
              ],
            ),
            TextField(
              controller: fotoController,
              decoration: const InputDecoration(labelText: 'URL da Foto (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
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

  Widget _buildMobileContent(ColorScheme cs, List<Atendimento> list) {
    final text = mobileSearchController.text.toLowerCase();
    final filtered = list.where((a) {
      final matchText = a.nomeCliente.toLowerCase().contains(text) ||
          a.telefoneCliente.contains(text);
      final matchState = mobileFilter == null || a.estado == mobileFilter;
      return matchText && matchState;
    }).toList();

    return Column(
      children: [
        if (isMobileSearching)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: mobileSearchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    isMobileSearching = false;
                    mobileSearchController.clear();
                  }),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
            child: Text(
              'Nenhum atendimento encontrado',
              style: TextStyle(
                fontSize: 18,
                color: cs.onSurfaceVariant,
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = filtered[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => ChatPage(
                      nome: a.nomeCliente,
                      numero: a.telefoneCliente,
                      fotoUrl: a.fotoUrl ?? '',
                    ),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                  ),
                ),
                child: ContatoCard(
                  nome: a.nomeCliente,
                  numero: a.telefoneCliente,
                  fotoUrl: a.fotoUrl ?? '',
                  estado: a.estado,
                  onEstadoChanged: (novo) {
                    final updated = a.copyWith(estado: novo);
                    context.read<AtendimentoModel>().atualizar(a.id, updated);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopKanban(
      ColorScheme cs,
      Map<EstadoAtendimento, List<Atendimento>> cols,
      ) {
    final totalWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 48.0; // 24 em cada lado
    final colCount = cols.length;
    final colWidth = (totalWidth - horizontalPadding) / colCount;

    return Listener(
      onPointerSignal: (sig) {
        if (sig is PointerScrollEvent) {
          final off = _scrollController.offset + sig.scrollDelta.dy;
          _scrollController.jumpTo(
            off.clamp(
              _scrollController.position.minScrollExtent,
              _scrollController.position.maxScrollExtent,
            ),
          );
        }
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(24),
          child: Row(
            children: cols.entries.map((e) {
              return Container(
                width: colWidth,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildColumn(cs, e.key, e.value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(
      ColorScheme cs,
      EstadoAtendimento estado,
      List<Atendimento> items,
      ) {
    final searching = isSearching[estado]!;
    final text = searchControllers[estado]!.text.toLowerCase();
    final filtered = items.where((a) {
      return a.nomeCliente.toLowerCase().contains(text) ||
          a.telefoneCliente.contains(text);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: headerColor[estado]!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: searching
                    ? _buildSearchField(cs, estado)
                    : Text(
                  estado.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerColor[estado],
                  ),
                ),
              ),
              if (!searching)
                IconButton(
                  icon: Icon(Icons.search, color: headerColor[estado]),
                  onPressed: () => setState(() => isSearching[estado] = true),
                ),
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
            builder: (context, cand, rej) {
              return Container(
                decoration: BoxDecoration(
                  color: cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = filtered[i];
                    return _buildDraggable(cs, a, estado);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(
      ColorScheme cs,
      EstadoAtendimento estado,
      ) {
    return TextField(
      controller: searchControllers[estado],
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: 'Pesquisar...',
        hintStyle: TextStyle(color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.close, color: cs.onSurface),
          onPressed: () => setState(() {
            isSearching[estado] = false;
            searchControllers[estado]!.clear();
          }),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDraggable(
      ColorScheme cs,
      Atendimento a,
      EstadoAtendimento origem,
      ) {
    return Draggable<Atendimento>(
      data: a,
      onDragStarted: () => colunaDragSource = origem,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: SizedBox(
            width: 220,
            child: ContatoCard(
              nome: a.nomeCliente,
              numero: a.telefoneCliente,
              fotoUrl: a.fotoUrl ?? '',
              estado: a.estado,
              onEstadoChanged: (novo) {
                final updated = a.copyWith(estado: novo);
                context.read<AtendimentoModel>().atualizar(a.id, updated);
              },
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: ContatoCard(
          nome: a.nomeCliente,
          numero: a.telefoneCliente,
          fotoUrl: a.fotoUrl ?? '',
          estado: a.estado,
          onEstadoChanged: (novo) {
            final updated = a.copyWith(estado: novo);
            context.read<AtendimentoModel>().atualizar(a.id, updated);
          },
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => ChatPage(
              nome: a.nomeCliente,
              numero: a.telefoneCliente,
              fotoUrl: a.fotoUrl ?? '',
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
        child: ContatoCard(
          nome: a.nomeCliente,
          numero: a.telefoneCliente,
          fotoUrl: a.fotoUrl ?? '',
          estado: a.estado,
          onEstadoChanged: (novo) {
            final updated = a.copyWith(estado: novo);
            context.read<AtendimentoModel>().atualizar(a.id, updated);
          },
        ),
      ),
    );
  }
}