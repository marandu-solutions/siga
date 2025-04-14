import 'package:flutter/material.dart';

class AlertaPage extends StatefulWidget {
  const AlertaPage({super.key});

  @override
  State<AlertaPage> createState() => _AlertaPageState();
}

class _AlertaPageState extends State<AlertaPage> {
  final TextEditingController motivoController = TextEditingController();
  String? pedidoSelecionado;

  final List<Map<String, String>> pedidos = [
    {'id': '001', 'nome': 'João Silva', 'detalhe': '100 camisas algodão'},
    {'id': '002', 'nome': 'Maria Souza', 'detalhe': '50 camisetas dri-fit'},
    {'id': '003', 'nome': 'Carlos Lima', 'detalhe': '200 camisas promocionais'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Painel lateral de pedidos
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pedidos com Atraso",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      final pedido = pedidos[index];
                      final bool isSelecionado = pedidoSelecionado == pedido['id'];

                      return GestureDetector(
                        onTap: () => setState(() {
                          pedidoSelecionado = pedido['id'];
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelecionado
                                ? Colors.purple.shade900.withOpacity(0.5)
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelecionado
                                  ? Colors.purpleAccent
                                  : Colors.grey.shade700,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purpleAccent,
                                child: Text(
                                  pedido['id']!,
                                  style: const TextStyle(
                                      color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pedido['nome']!,
                                      style: const TextStyle(color: Colors.white, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pedido['detalhe']!,
                                      style: TextStyle(color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Painel de mensagem
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Justificativa do Atraso",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pedidoSelecionado != null
                        ? "Você está notificando o pedido #$pedidoSelecionado"
                        : "Selecione um pedido para enviar uma justificativa.",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: TextField(
                      controller: motivoController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Descreva o que aconteceu...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: const Color(0xFF2E2E3E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: pedidoSelecionado == null
                          ? null
                          : () {
                        // Enviar alerta
                      },
                      icon: const Icon(Icons.send),
                      label: const Text("Enviar Alerta"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pedidoSelecionado == null
                            ? Colors.grey.shade800
                            : Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
