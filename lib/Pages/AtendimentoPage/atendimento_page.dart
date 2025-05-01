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

  void _moveCard(Map<String, String> cardData, String from, String to) {
    setState(() {
      cardsPorColuna[from]!.remove(cardData);
      cardsPorColuna[to]!.add(cardData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colunas = cardsPorColuna.keys.toList();
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width < 600) {
            return _buildMobileView(colunas);
          }
          if (width < 900) {
            return _buildIntermediateView(colunas, constraints.maxHeight);
          }
          return _buildDesktopView(colunas);
        },
      ),
    );
  }

  Widget _buildMobileView(List<String> colunas) {
    return DefaultTabController(
      length: colunas.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.deepPurpleAccent,
            tabs: colunas.map((c) => Tab(text: c)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: colunas
                  .map((c) => Padding(
                padding: const EdgeInsets.all(12),
                child: _buildColumnContent(c, colunas),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Intermediate between mobile and desktop: horizontal scroll
  Widget _buildIntermediateView(List<String> colunas, double height) {
    final colWidth = (MediaQuery.of(context).size.width - 48) / 2;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: colunas.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: colWidth,
              height: height - 40,
              child: _buildColumnContent(c, colunas),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDesktopView(List<String> colunas) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: colunas.map((c) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildColumnContent(c, colunas),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumnContent(String coluna, List<String> colunas) {
    final searching = isSearching[coluna]!;
    final text = searchControllers[coluna]!.text.toLowerCase();
    final cards = cardsPorColuna[coluna]!
        .where((card) =>
    card['nome']!.toLowerCase().contains(text) ||
        card['numero']!.toLowerCase().contains(text))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            color: headerColor[coluna]!.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: searching
                    ? _buildSearchField(coluna)
                    : Text(
                  coluna,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerColor[coluna]!.withOpacity(1),
                  ),
                ),
              ),
              if (!searching)
                IconButton(
                  icon: Icon(Icons.search,
                      color: headerColor[coluna]!.withOpacity(0.8)),
                  onPressed: () => setState(() => isSearching[coluna] = true),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2F),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: ListView.separated(
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildCardItem(cards[i], coluna, colunas),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(String coluna) => TextField(
    controller: searchControllers[coluna],
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: 'Pesquisar...',
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF2A2A40),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => setState(() {
          isSearching[coluna] = false;
          searchControllers[coluna]!.clear();
        }),
      ),
    ),
    onChanged: (_) => setState(() {}),
  );

  Widget _buildCardItem(Map<String, String> card, String coluna, List<String> colunas) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (_, __, ___) => ChatPage(
                  nome: card['nome']!,
                  numero: card['numero']!,
                  fotoUrl: card['foto']!,
                ),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
              ),
            );
          },
          child: ContatoCard(
            nome: card['nome']!,
            numero: card['numero']!,
            fotoUrl: card['foto']!,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (colunas.indexOf(coluna) > 0)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => _moveCard(card, coluna, colunas[colunas.indexOf(coluna) - 1]),
              ),
            if (colunas.indexOf(coluna) < colunas.length - 1)
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () => _moveCard(card, coluna, colunas[colunas.indexOf(coluna) + 1]),
              ),
          ],
        ),
      ],
    );
  }
}