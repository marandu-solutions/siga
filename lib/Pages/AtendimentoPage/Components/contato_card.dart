import 'package:flutter/material.dart';
// Supondo que o seu enum esteja no mesmo arquivo da página de atendimento ou em um local acessível.
import '../atendimento_page.dart';

class ContatoCard extends StatelessWidget {
  final String nome;
  final String numero;
  final String fotoUrl;
  // ✅ O 'status' agora é recebido como uma String (ex: "Em Aberto").
  final String status;
  // ✅ O callback agora emite uma String.
  final ValueChanged<String> onEstadoChanged;
  final VoidCallback? onTap;

  const ContatoCard({
    super.key,
    required this.nome,
    required this.numero,
    required this.fotoUrl,
    required this.status,
    required this.onEstadoChanged,
    this.onTap,
  });

  // ✅ A função de cor agora recebe uma String, mas usa o enum internamente para a lógica.
  Color _getStatusColor(BuildContext context, String statusLabel) {
    final estado = EstadoAtendimento.fromString(statusLabel);
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
    // ✅ Passa a String do status para obter a cor.
    final estadoColor = _getStatusColor(context, status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                onBackgroundImageError: fotoUrl.isNotEmpty ? (_, __) {} : null,
                backgroundColor: cs.surfaceContainerHighest,
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
                      status, // ✅ Exibe a String de status diretamente.
                      style: textTheme.labelSmall?.copyWith(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusPopupMenu(
                    estadoAtual: status,
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

// ===================================================================
// ==================== _StatusPopupMenu ATUALIZADO ==================
// ===================================================================

class _StatusPopupMenu extends StatelessWidget {
  const _StatusPopupMenu({
    required this.estadoAtual,
    required this.onEstadoChanged,
    required this.estadoColor,
  });

  // ✅ Recebe e emite Strings.
  final String estadoAtual;
  final ValueChanged<String> onEstadoChanged;
  final Color estadoColor;

  @override
  Widget build(BuildContext context) {
    // ✅ O tipo do PopupMenuButton agora é String.
    return PopupMenuButton<String>(
      initialValue: estadoAtual,
      onSelected: onEstadoChanged,
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
      itemBuilder: (BuildContext context) {
        // Gera os itens do menu a partir do enum, mas o 'value' de cada item é a String do label.
        return EstadoAtendimento.values.map((e) {
          return PopupMenuItem<String>(
            value: e.label,
            child: Text(e.label),
          );
        }).toList();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}