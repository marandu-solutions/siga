import 'package:flutter/material.dart';

class ContatoCard extends StatelessWidget {
  final String nome;
  final String numero;
  final String fotoUrl;

  const ContatoCard({
    super.key,
    required this.nome,
    required this.numero,
    required this.fotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,                // Fundo do card usando surface
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(fotoUrl),
              radius: 20,
              backgroundColor: cs.surfaceVariant, // Borda sutil no avatar
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,       // Texto usando onSurface
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    numero,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant, // Texto secundário
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
