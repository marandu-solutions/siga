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
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coluna,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          final cards = cardsPorColuna[coluna]!;

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
