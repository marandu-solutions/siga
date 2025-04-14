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
        {"texto": "Gostaria de um orçamento.", "remetente": "cliente", "hora": "09:11"},
        {"texto": "Claro, posso te ajudar com isso!", "remetente": "loja", "hora": "09:12"},
      ],
    },
    {
      "nome": "Pedro Paulo",
      "foto": "https://i.pravatar.cc/150?img=5",
      "mensagens": [
        {"texto": "Vocês fazem camisas polo personalizadas?", "remetente": "cliente", "hora": "08:45"},
        {"texto": "Fazemos sim! Posso te mostrar alguns modelos.", "remetente": "loja", "hora": "08:46"},
      ],
    },
  ];

  void enviarMensagem() {
    if (_mensagemController.text.trim().isEmpty) return;

    setState(() {
      contatos[contatoSelecionado]["mensagens"].add({
        "texto": _mensagemController.text.trim(),
        "remetente": "loja",
        "hora": TimeOfDay.now().format(context),
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
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Sidebar de contatos
              Container(
                width: 260,
                color: const Color(0xFF1C1C2E),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Contatos",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: contatos.length,
                        itemBuilder: (context, index) {
                          final contato = contatos[index];
                          final isSelected = index == contatoSelecionado;
                          final isHovered = index == contatoHoverIndex;

                          Color backgroundColor = Colors.transparent;
                          if (isSelected) {
                            backgroundColor = Colors.deepPurple.withOpacity(0.3);
                          } else if (isHovered) {
                            backgroundColor = Colors.deepPurple.withOpacity(0.15);
                          }

                          return MouseRegion(
                            onEnter: (_) => setState(() => contatoHoverIndex = index),
                            onExit: (_) => setState(() => contatoHoverIndex = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade800,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(contato["foto"]),
                                ),
                                title: Text(
                                  contato["nome"],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () => setState(() => contatoSelecionado = index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Área de conversa
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/whatsapp_background.png',
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.2),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: contatos[contatoSelecionado]["mensagens"].length,
                            itemBuilder: (context, index) {
                              final mensagem = contatos[contatoSelecionado]["mensagens"][index];
                              final isLoja = mensagem["remetente"] == "loja";

                              return Align(
                                alignment: isLoja ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  decoration: BoxDecoration(
                                    color: isLoja ? Colors.deepPurple.shade400 : const Color(0xFF2C2C3E),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(2, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        mensagem["texto"],
                                        style: const TextStyle(fontSize: 15, color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mensagem["hora"] ?? '',
                                        style: const TextStyle(fontSize: 11, color: Colors.white70),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1C1C2E),
                            border: Border(
                              top: BorderSide(color: Colors.deepPurple),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _mensagemController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "Digite sua mensagem...",
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => enviarMensagem(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                                onPressed: enviarMensagem,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
