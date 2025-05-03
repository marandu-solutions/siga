// lib/Pages/AtendimentoPage/atendimento_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siga/Pages/AtendimentoPage/Components/contato_card.dart';
import 'package:siga/Pages/AtendimentoPage/Components/chat_page.dart';
import 'package:siga/Model/pedidos.dart';
import 'package:siga/Model/pedidos_model.dart';

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
    EstadoPedido.emAberto: Colors.deepPurpleAccent,
    EstadoPedido.emAndamento: Colors.tealAccent,
    EstadoPedido.entregaRetirada: Colors.amberAccent,
    EstadoPedido.finalizado: Colors.greenAccent,
    EstadoPedido.cancelado: Colors.redAccent,
  };

  @override
  void initState() {
    super.initState();
    for (var estado in EstadoPedido.values) {
      isSearching[estado] = false;
      searchControllers[estado] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var ctrl in searchControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    final pedidos = context.watch<PedidoModel>().pedidos;
    final cardsPorColuna = {
      for (var estado in EstadoPedido.values)
        estado: pedidos.where((p) => p.estado == estado).toList(),
    };

    return Scaffold(
      backgroundColor: cs.surface,
      body: isMobile
          ? _buildMobileListView(cs, pedidos)
          : _buildDesktopKanban(cs, cardsPorColuna),
    );
  }

  // Mobile: simple WhatsApp-style list
  Widget _buildMobileListView(ColorScheme cs, List<Pedido> pedidos) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: pedidos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final pedido = pedidos[i];
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
          ),
        );
      },
    );
  }

  // Desktop: fixed-width Kanban with horizontal scroll
  Widget _buildDesktopKanban(
      ColorScheme cs,
      Map<EstadoPedido, List<Pedido>> cardsPorColuna,
      ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: cardsPorColuna.entries.map((entry) {
          return Container(
            width: 280, // fixed column width
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildColumnContent(
              cs,
              entry.key,
              entry.value,
            ),
          );
        }).toList(),
      ),
    );
  }

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
        ),
      ),
    );
  }
}