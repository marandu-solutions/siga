// lib/Pages/AtendimentoPage/atendimento_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siga/Pages/AtendimentoPage/Components/contato_card.dart';
import 'package:siga/Pages/AtendimentoPage/Components/chat_page.dart';
import 'package:siga/Model/pedidos.dart';
import 'package:siga/Model/pedidos_model.dart';
import 'dart:ui'; // Para PointerDeviceKind

class AtendimentoPage extends StatefulWidget {
  const AtendimentoPage({Key? key}) : super(key: key);

  @override
  State<AtendimentoPage> createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  EstadoPedido? colunaDragSource;
  final Map<EstadoPedido, bool> isSearching = {};
  final Map<EstadoPedido, TextEditingController> searchControllers = {};
  final Map<EstadoPedido, Color> headerColor = {
    EstadoPedido.emAberto: Colors.purple.shade500,
    EstadoPedido.emAndamento: Colors.amber.shade600,
    EstadoPedido.entregaRetirada: Colors.orange.shade700,
    EstadoPedido.finalizado: Colors.green.shade700,
    EstadoPedido.cancelado: Colors.red.shade700,
  };

  // Mobile search e filtro
  bool isMobileSearching = false;
  late TextEditingController mobileSearchController;
  EstadoPedido? mobileFilter;

  // Controlador para scroll horizontal no desktop
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    for (var estado in EstadoPedido.values) {
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
    final themes = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    final pedidos = context.watch<PedidoModel>().pedidos;
    final cardsPorColuna = {
      for (var estado in EstadoPedido.values)
        estado: pedidos.where((p) => p.estado == estado).toList(),
    };

    return Scaffold(
      backgroundColor: themes.appBarTheme.backgroundColor,
      appBar: isMobile
          ? AppBar(
        title: const Text('Atendimento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() {
              isMobileSearching = !isMobileSearching;
              if (!isMobileSearching) {
                mobileSearchController.clear();
              }
            }),
          ),
          PopupMenuButton<EstadoPedido?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (novo) => setState(() {
              mobileFilter = novo;
            }),
            itemBuilder: (_) {
              return [
                const PopupMenuItem<EstadoPedido?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...EstadoPedido.values.map((e) => PopupMenuItem(
                  value: e,
                  child: Text(e.label),
                )),
              ];
            },
          ),
        ],
      )
          : null,
      body: isMobile
          ? _buildMobileContent(cs, pedidos)
          : _buildDesktopKanban(cs, cardsPorColuna),
    );
  }

  /// Mobile: campo de pesquisa e lista/vazio
  Widget _buildMobileContent(ColorScheme cs, List<Pedido> pedidos) {
    final text = mobileSearchController.text.toLowerCase();
    final filtered = pedidos.where((p) {
      final matchText = p.nomeCliente.toLowerCase().contains(text) || p.telefoneCliente.contains(text);
      final matchState = mobileFilter == null || p.estado == mobileFilter;
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
              final pedido = filtered[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => ChatPage(
                      nome: pedido.nomeCliente,
                      numero: pedido.telefoneCliente,
                      fotoUrl: pedido.fotoUrl ?? '',
                    ),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                  ),
                ),
                child: ContatoCard(
                  nome: pedido.nomeCliente,
                  numero: pedido.telefoneCliente,
                  fotoUrl: pedido.fotoUrl ?? '',
                  estado: pedido.estado,
                  onEstadoChanged: (novoEstado) {
                    final atualizado = pedido.copyWith(estado: novoEstado);
                    context.read<PedidoModel>().atualizarPedido(pedido.id, atualizado);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Desktop: Kanban com scroll horizontal
  Widget _buildDesktopKanban(
      ColorScheme cs,
      Map<EstadoPedido, List<Pedido>> cardsPorColuna,
      ) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final newOffset =
              _scrollController.offset + pointerSignal.scrollDelta.dy;
          final clamped = newOffset.clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          );
          _scrollController.jumpTo(clamped);
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
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(24),
          child: Row(
            children: cardsPorColuna.entries.map((entry) {
              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildColumnContent(
                  cs,
                  entry.key,
                  entry.value,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Coluna individual do Kanban
  Widget _buildColumnContent(
      ColorScheme cs,
      EstadoPedido estado,
      List<Pedido> listaOriginal,
      ) {
    final searching = isSearching[estado]!;
    final text = searchControllers[estado]!.text.toLowerCase();
    final listaFiltrada = listaOriginal.where((p) {
      return p.nomeCliente.toLowerCase().contains(text) ||
          p.telefoneCliente.contains(text);
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
                  onPressed: () => setState(() {
                    isSearching[estado] = true;
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: DragTarget<Pedido>(
            onWillAccept: (_) => true,
            onAccept: (pedido) {
              if (colunaDragSource != null) {
                final atualizado = pedido.copyWith(estado: estado);
                context.read<PedidoModel>().atualizarPedido(
                  pedido.id,
                  atualizado,
                );
              }
            },
            builder: (context, candidate, rejected) {
              return Container(
                decoration: BoxDecoration(
                  color: cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: ListView.separated(
                  itemCount: listaFiltrada.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final pedido = listaFiltrada[i];
                    return _buildDraggableCard(cs, pedido, estado);
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
      EstadoPedido estado,
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

  Widget _buildDraggableCard(
      ColorScheme cs,
      Pedido pedido,
      EstadoPedido estadoOrigem,
      ) {
    return Draggable<Pedido>(
      data: pedido,
      onDragStarted: () => colunaDragSource = estadoOrigem,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: SizedBox(
            width: 220,
              child: ContatoCard(
                nome: pedido.nomeCliente,
                numero: pedido.telefoneCliente,
                fotoUrl: pedido.fotoUrl ?? '',
                estado: pedido.estado,
                onEstadoChanged: (novoEstado) {
                  final atualizado = pedido.copyWith(estado: novoEstado);
                  context.read<PedidoModel>().atualizarPedido(pedido.id, atualizado);
                },
              ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: ContatoCard(
          nome: pedido.nomeCliente,
          numero: pedido.telefoneCliente,
          fotoUrl: pedido.fotoUrl ?? '',
          estado: pedido.estado,
          onEstadoChanged: (novoEstado) {
            final atualizado = pedido.copyWith(estado: novoEstado);
            context.read<PedidoModel>().atualizarPedido(pedido.id, atualizado);
          },
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => ChatPage(
              nome: pedido.nomeCliente,
              numero: pedido.telefoneCliente,
              fotoUrl: pedido.fotoUrl ?? '',
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
        child: ContatoCard(
          nome: pedido.nomeCliente,
          numero: pedido.telefoneCliente,
          fotoUrl: pedido.fotoUrl ?? '',
          estado: pedido.estado,
          onEstadoChanged: (novoEstado) {
            final atualizado = pedido.copyWith(estado: novoEstado);
            context.read<PedidoModel>().atualizarPedido(pedido.id, atualizado);
          },
        ),
      ),
    );
  }
}
