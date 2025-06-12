import 'package:flutter/material.dart';
// Supondo que o seu modelo esteja neste caminho
import '../../../Model/atendimento.dart';

class ContatoCard extends StatelessWidget {
  final String nome;
  final String numero;
  final String fotoUrl;
  final EstadoAtendimento estado;
  final ValueChanged<EstadoAtendimento> onEstadoChanged;
  final VoidCallback? onTap; // <-- ADIÇÃO CRUCIAL AQUI

  const ContatoCard({
    super.key,
    required this.nome,
    required this.numero,
    required this.fotoUrl,
    required this.estado,
    required this.onEstadoChanged,
    this.onTap, // <-- ADIÇÃO CRUCIAL AQUI
  });

  // Função para obter a cor correta baseada no tema
  Color _getStatusColor(BuildContext context, EstadoAtendimento estado) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (estado) {
      case EstadoAtendimento.emAberto:
        return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      case EstadoAtendimento.emAndamento:
        return isDark ? Colors.amber.shade300 : Colors.amber.shade800;
      case EstadoAtendimento.finalizado:
        return isDark ? Colors.green.shade400 : Colors.green.shade800;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final estadoColor = _getStatusColor(context, estado);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      clipBehavior: Clip.antiAlias, // Garante que o InkWell respeite as bordas
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // <-- MUDANÇA CRUCIAL AQUI
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                onBackgroundImageError: fotoUrl.isNotEmpty ? (_, __) {} : null,
                backgroundColor: cs.surfaceVariant,
                child: fotoUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      numero,
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estado.label,
                      style: textTheme.labelSmall?.copyWith(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusPopupMenu(
                    estado: estado,
                    onEstadoChanged: onEstadoChanged,
                    estadoColor: estadoColor,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPopupMenu extends StatelessWidget {
  const _StatusPopupMenu({
    required this.estado,
    required this.onEstadoChanged,
    required this.estadoColor,
  });

  final EstadoAtendimento estado;
  final ValueChanged<EstadoAtendimento> onEstadoChanged;
  final Color estadoColor;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<EstadoAtendimento>(
      initialValue: estado,
      onSelected: onEstadoChanged,
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
      itemBuilder: (BuildContext context) {
        return EstadoAtendimento.values.map((e) {
          return PopupMenuItem<EstadoAtendimento>(
            value: e,
            child: Text(e.label),
          );
        }).toList();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
