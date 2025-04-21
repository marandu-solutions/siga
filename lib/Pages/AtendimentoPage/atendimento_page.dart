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

  String? colunaDragSource;

  final Map<String, bool> isSearching = {};
  final Map<String, TextEditingController> searchControllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar estados de busca
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

  @override
  Widget build(BuildContext context) {
    final colunas = cardsPorColuna.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: colunas.map((coluna) {
            final isColumnSearching = isSearching[coluna]!;
            final searchText = searchControllers[coluna]!.text.toLowerCase();
            final cards = cardsPorColuna[coluna]!
                .where((card) =>
            card["nome"]!.toLowerCase().contains(searchText) ||
                card["numero"]!.toLowerCase().contains(searchText))
                .toList();

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra superior da coluna (com ícones ou campo de busca)
                    Row(
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
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    isSearching[coluna] = false;
                                    searchControllers[coluna]!.clear();
                                  });
                                },
                              ),
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          )
                              : Text(
                            coluna,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isColumnSearching) ...[
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                isSearching[coluna] = true;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            tooltip: "Atualizar",
                            onPressed: () {
                              // Lógica de atualização específica da coluna (se necessário)
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            tooltip: "Configurações",
                            onPressed: () {
                              // Futuro: configurações da coluna
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Área dos cards da coluna
                    Expanded(
                      child: DragTarget<Map<String, String>>(
                        onWillAccept: (data) => true,
                        onAccept: (data) {
                          if (colunaDragSource != null) {
                            setState(() {
                              cardsPorColuna[colunaDragSource!]!.remove(data);
                              cardsPorColuna[coluna]!.add(data);
                            });
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E2F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: ListView.builder(
                              itemCount: cards.length,
                              itemBuilder: (context, index) {
                                final cardData = cards[index];

                                return Draggable<Map<String, String>>(
                                  data: cardData,
                                  onDragStarted: () {
                                    colunaDragSource = coluna;
                                  },
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Opacity(
                                      opacity: 0.85,
                                      child: SizedBox(
                                        width: 220,
                                        child: ContatoCard(
                                          nome: cardData["nome"]!,
                                          numero: cardData["numero"]!,
                                          fotoUrl: cardData["foto"]!,
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.4,
                                    child: ContatoCard(
                                      nome: cardData["nome"]!,
                                      numero: cardData["numero"]!,
                                      fotoUrl: cardData["foto"]!,
                                    ),
                                  ),
                                  child: GestureDetector(
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
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
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
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
