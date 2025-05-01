import 'package:flutter/material.dart';
import 'package:siga/Pages/AtendimentoPage/Components/contato_card.dart';
import 'package:siga/Pages/AtendimentoPage/Components/chat_page.dart';

class AtendimentoPage extends StatefulWidget {
  const AtendimentoPage({Key? key}) : super(key: key);

  @override
  State<AtendimentoPage> createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  final Map<String, List<Map<String, String>>> cardsPorColuna = {
    'Em aberto': [
      {
        'nome': 'João Silva',
        'numero': '(84) 91234-5678',
        'foto': 'https://i.pravatar.cc/150?img=3',
      },
      {
        'nome': 'Pedro Paulo',
        'numero': '(84) 99876-5432',
        'foto': 'https://i.pravatar.cc/150?img=5',
      },
    ],
    'Em atendimento': [],
    'Pendências': [],
    'Finalizado': [],
  };

  final Map<String, Color> headerColor = {
    'Em aberto': Colors.deepPurpleAccent,
    'Em atendimento': Colors.tealAccent,
    'Pendências': Colors.amberAccent,
    'Finalizado': Colors.greenAccent,
  };

  String? colunaDragSource;
  final Map<String, bool> isSearching = {};
  final Map<String, TextEditingController> searchControllers = {};

  @override
  void initState() {
    super.initState();
    for (var coluna in cardsPorColuna.keys) {
      isSearching[coluna] = false;
      searchControllers[coluna] = TextEditingController();
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
    final colunas = cardsPorColuna.keys.toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileView(cs, colunas);
          } else {
            return _buildDesktopView(cs, colunas);
          }
        },
      ),
    );
  }

  Widget _buildMobileView(ColorScheme cs, List<String> colunas) {
    return DefaultTabController(
      length: colunas.length,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: TabBarView(
          children: colunas.map((c) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: _buildColumnContent(cs, c),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDesktopView(ColorScheme cs, List<String> colunas) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: colunas.map((c) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildColumnContent(cs, c),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumnContent(ColorScheme cs, String coluna) {
    final searching = isSearching[coluna]!;
    final text = searchControllers[coluna]!.text.toLowerCase();
    final cards = cardsPorColuna[coluna]!
        .where((card) =>
    card['nome']!.toLowerCase().contains(text) ||
        card['numero']!.contains(text))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: headerColor[coluna]!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: searching
                    ? _buildSearchField(cs, coluna)
                    : Text(
                  coluna,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerColor[coluna]!,
                  ),
                ),
              ),
              if (!searching)
                IconButton(
                  icon: Icon(Icons.search, color: headerColor[coluna]!),
                  onPressed: () => setState(() {
                    isSearching[coluna] = true;
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: DragTarget<Map<String, String>>(
            onWillAccept: (_) => true,
            onAccept: (data) {
              if (colunaDragSource != null) {
                setState(() {
                  cardsPorColuna[colunaDragSource!]!.remove(data);
                  cardsPorColuna[coluna]!.add(data);
                });
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
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _buildDraggableCard(cs, cards[i], coluna),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(ColorScheme cs, String coluna) {
    return TextField(
      controller: searchControllers[coluna],
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
            isSearching[coluna] = false;
            searchControllers[coluna]!.clear();
          }),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDraggableCard(
      ColorScheme cs, Map<String, String> card, String coluna) {
    return Draggable<Map<String, String>>(
      data: card,
      onDragStarted: () => colunaDragSource = coluna,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: SizedBox(
            width: 220,
            child: ContatoCard(
              nome: card['nome']!,
              numero: card['numero']!,
              fotoUrl: card['foto']!,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: ContatoCard(
          nome: card['nome']!,
          numero: card['numero']!,
          fotoUrl: card['foto']!,
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => ChatPage(
              nome: card['nome']!,
              numero: card['numero']!,
              fotoUrl: card['foto']!,
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
        child: ContatoCard(
          nome: card['nome']!,
          numero: card['numero']!,
          fotoUrl: card['foto']!,
        ),
      ),
    );
  }
}
