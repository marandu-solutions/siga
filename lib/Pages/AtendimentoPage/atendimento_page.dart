import 'package:flutter/material.dart';
import 'package:siga/Pages/AtendimentoPage/Components/contato_card.dart';
import 'package:siga/Pages/AtendimentoPage/Components/chat_page.dart';

class AtendimentoPage extends StatefulWidget {
  const AtendimentoPage({super.key});

  @override
  State<AtendimentoPage> createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  final Map<String, List<Map<String, String>>> cardsPorColuna = {
    "Em aberto": [
      {
        "nome": "João Silva",
        "numero": "(84) 91234-5678",
        "foto": "https://i.pravatar.cc/150?img=3",
      },
      {
        "nome": "Pedro Paulo",
        "numero": "(84) 99876-5432",
        "foto": "https://i.pravatar.cc/150?img=5",
      },
    ],
    "Em atendimento": [],
    "Pendências": [],
    "Finalizado": [],
  };

  // Cores de fundo para cabeçalhos, garantindo contraste
  final Map<String, Color> headerColor = {
    "Em aberto": Colors.deepPurpleAccent,
    "Em atendimento": Colors.tealAccent,
    "Pendências": Colors.amberAccent,
    "Finalizado": Colors.greenAccent,
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
    for (var controller in searchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _moveCard(
      Map<String, String> cardData, String fromColumn, String toColumn) {
    setState(() {
      cardsPorColuna[fromColumn]!.remove(cardData);
      cardsPorColuna[toColumn]!.add(cardData);
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
          final height = constraints.maxHeight;

          if (width < 600) {
            return DefaultTabController(
              length: colunas.length,
              child: Column(
                children: [
                TabBar(
                isScrollable: true,
                labelColor: Colors.deepPurpleAccent,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.deepPurpleAccent,
                indicatorWeight: 3,
                tabs: colunas.map((c) => Tab(text: c)).toList(),
                ),
          Expanded(
          child: TabBarView(
          children: colunas
              .map((c) => _buildColumnContent(c, colunas))
              .toList(),
          ),
          ),
          ],
          ),
          );
          }

          if (width < 900) {
          final colWidth = (width - 16 * 3) / 2;
          return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colunas.map((c) {
          return SizedBox(
          width: colWidth,
          height: height - 32,
          child: _buildColumnContent(c, colunas,
          constrainedHeight: height - 32),
          );
          }).toList(),
          ),
          );
          }

          return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: colunas.map((c) {
          return Expanded(
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildColumnContent(c, colunas),
          ),
          );
          }).toList(),
          ),
          );
        },
      ),
    );
  }

  Widget _buildColumnContent(
      String coluna, List<String> colunas,
      {double? constrainedHeight}) {
    final isColumnSearching = isSearching[coluna]!;
    final searchText = searchControllers[coluna]!.text.toLowerCase();
    final cards = cardsPorColuna[coluna]!
        .where((card) =>
    card["nome"]!.toLowerCase().contains(searchText) ||
        card["numero"]!.toLowerCase().contains(searchText))
        .toList();

    Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho colorido com contraste
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: headerColor[coluna]!.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: isColumnSearching
                    ? TextField(
                  controller: searchControllers[coluna],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Pesquisar...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2A2A40),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon:
                      const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isSearching[coluna] = false;
                          searchControllers[coluna]!.clear();
                        });
                      },
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                )
                    : Text(
                  coluna,
                  style: TextStyle(
                    color: headerColor[coluna]!.withOpacity(1),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isColumnSearching)
                IconButton(
                  icon: Icon(Icons.search,
                      color: headerColor[coluna]!.withOpacity(0.8)),
                  onPressed: () => setState(() => isSearching[coluna] = true),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2F),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) => _buildCardWithArrows(
                  coluna, colunas, cards[index]),
            ),
          ),
        ),
      ],
    );

    if (constrainedHeight != null) {
      return SizedBox(height: constrainedHeight, child: column);
    }
    return column;
  }

  Widget _buildCardWithArrows(
      String coluna, List<String> colunas, Map<String, String> cardData) {
    final currentIdx = colunas.indexOf(coluna);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (_, __, ___) => ChatPage(
                  nome: cardData["nome"]!,
                  numero: cardData["numero"]!,
                  fotoUrl: cardData["foto"]!,
                ),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: ContatoCard(
            nome: cardData["nome"]!,
            numero: cardData["numero"]!,
            fotoUrl: cardData["foto"]!,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (currentIdx > 0)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => _moveCard(
                    cardData, coluna, colunas[currentIdx - 1]),
              ),
            if (currentIdx < colunas.length - 1)
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () => _moveCard(
                    cardData, coluna, colunas[currentIdx + 1]),
              ),
          ],
        ),
      ],
    );
  }
}
