import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  final VoidCallback? onTap; // Parâmetro que estava faltando

  const MetricCard({
    Key? key,
    required this.icon,
    required this.number,
    required this.label,
    this.onTap, // Adicionado ao construtor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      child: InkWell(
        // O onTap agora é usado aqui
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(number, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}