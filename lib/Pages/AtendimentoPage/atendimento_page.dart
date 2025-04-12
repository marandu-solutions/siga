import 'package:flutter/material.dart';

class AtendimentoPage extends StatefulWidget {
  const AtendimentoPage({super.key});

  @override
  State<AtendimentoPage> createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  final TextEditingController _mensagemController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int contatoSelecionado = 0;
  int? contatoHoverIndex;

  final List<Map<String, dynamic>> contatos = [
    {
      "nome": "João Silva",
      "foto": "https://i.pravatar.cc/150?img=3",
      "mensagens": [
        {"texto": "Olá, tudo bem?", "remetente": "cliente", "hora": "09:10"},
        {
          "texto": "Gostaria de um orçamento.",
          "remetente": "cliente",
          "hora": "09:11"
        },
        {
          "texto": "Claro, posso te ajudar com isso!",
          "remetente": "loja",
          "hora": "09:12"
        },
      ],
    },
    {
      "nome": "Pedro Paulo",
      "foto": "https://i.pravatar.cc/150?img=5",
      "mensagens": [
        {
          "texto": "Vocês fazem camisas polo personalizadas?",
          "remetente": "cliente",
          "hora": "08:45"
        },
        {
          "texto": "Fazemos sim! Posso te mostrar alguns modelos.",
          "remetente": "loja",
          "hora": "08:46"
        },
      ],
    },
  ];

  void enviarMensagem() {
    if (_mensagemController.text.trim().isEmpty) return;

    setState(() {
      contatos[contatoSelecionado]["mensagens"].add({
        "texto": _mensagemController.text.trim(),
        "remetente": "loja",
        "hora": TimeOfDay.now().format(context)
      });
      _mensagemController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300, // Borda cinza mais externa (efeito 3D)
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(6), // Espaço para borda branca interna
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Fundo branco "janela"
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Sidebar de Contatos
                Container(
                  width: 250,
                  color: Colors.grey.shade200,
                  child: ListView.builder(
                    itemCount: contatos.length,
                    itemBuilder: (context, index) {
                      final contato = contatos[index];
                      final isSelected = index == contatoSelecionado;
                      final isHovered = index == contatoHoverIndex;

                      Color backgroundColor = Colors.transparent;
                      if (isSelected) {
                        backgroundColor = Colors.blue.shade100;
                      } else if (isHovered) {
                        backgroundColor = Colors.blue.shade50;
                      }

                      return MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            contatoHoverIndex = index;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            contatoHoverIndex = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(contato["foto"]),
                            ),
                            title: Text(contato["nome"]),
                            onTap: () {
                              setState(() {
                                contatoSelecionado = index;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Área de Conversa
                Expanded(
                  child: Stack(
                    children: [
                      // Fundo da conversa
                      Positioned.fill(
                        child: Image.asset(
                          'assets/whatsapp_background.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount:
                              contatos[contatoSelecionado]["mensagens"]
                                  .length,
                              itemBuilder: (context, index) {
                                final mensagem = contatos[contatoSelecionado]
                                ["mensagens"][index];
                                final isLoja =
                                    mensagem["remetente"] == "loja";

                                return Align(
                                  alignment: isLoja
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                    constraints:
                                    const BoxConstraints(maxWidth: 400),
                                    decoration: BoxDecoration(
                                      color: isLoja
                                          ? Colors.green.shade100
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .end,
                                      children: [
                                        Text(
                                          mensagem["texto"],
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          mensagem["hora"] ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Campo de digitação
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _mensagemController,
                                    decoration: const InputDecoration(
                                      hintText: "Digite sua mensagem...",
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => enviarMensagem(),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send,
                                      color: Colors.blueAccent),
                                  onPressed: enviarMensagem,
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }