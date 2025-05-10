// lib/Pages/AtendimentoPage/Components/contato_card.dart
import 'package:flutter/material.dart';
import 'package:siga/Model/atendimento.dart';

class ContatoCard extends StatelessWidget {
  final String nome;
  final String numero;
  final String fotoUrl;
  final EstadoAtendimento estado;
  final ValueChanged<EstadoAtendimento> onEstadoChanged;

  const ContatoCard({
    super.key,
    required this.nome,
    required this.numero,
    required this.fotoUrl,
    required this.estado,
    required this.onEstadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // mapeamento de cores por estado
    final estadoColor = {
      EstadoAtendimento.emAberto: Colors.purple.shade500,
      EstadoAtendimento.emAndamento: Colors.amber.shade700,
      EstadoAtendimento.finalizado: Colors.green.shade700,
    }[estado]!;

    // detecta tela estreita (<900px)
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Card(
      color: cs.surface,
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
              backgroundColor: cs.surfaceVariant,
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
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    estado.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: estadoColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    numero,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isMobile)
              DropdownButton<EstadoAtendimento>(
                value: estado,
                underline: const SizedBox(),
                items: EstadoAtendimento.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.label, style: TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (novo) {
                  if (novo != null) onEstadoChanged(novo);
                },
              ),
          ],
        ),
      ),
    );
  }
}