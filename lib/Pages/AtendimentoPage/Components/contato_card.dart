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
    return Card(
      color: const Color(0xFF2A2A3E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6), // reduzido de 8 para 6
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // padding mais compacto
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(fotoUrl),
              radius: 20, // reduzido de 24 para 20
            ),
            const SizedBox(width: 8), // reduzido de 12 para 8
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 15,           // levemente menor
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4), // mantido em 4dp
                  Text(
                    numero,
                    style: const TextStyle(
                      fontSize: 12,           // reduzido de 13 para 12
                      color: Colors.white70,
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
