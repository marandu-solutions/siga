import 'package:flutter/material.dart';

class FeedbacksPage extends StatelessWidget {
  final List<Map<String, String>> feedbacks = [
    {
      'numero': '+55 84 91234-5678',
      'nome': 'João Silva',
      'mensagem': 'Excelente atendimento, muito rápido e eficiente!',
    },
    {
      'numero': '+55 84 98765-4321',
      'nome': 'Maria Souza',
      'mensagem': 'Gostei muito das camisetas, só achei a entrega um pouco lenta.',
    },
    {
      'numero': '+55 84 99876-1122',
      'nome': 'Carlos Lima',
      'mensagem': 'Serviço ótimo, voltarei a comprar com certeza!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Feedbacks dos Clientes",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: feedbacks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final feedback = feedbacks[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF262649),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.deepPurpleAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feedback['nome'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              feedback['numero'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feedback['mensagem'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
