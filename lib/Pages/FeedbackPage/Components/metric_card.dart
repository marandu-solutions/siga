import 'package:flutter/material.dart';

/// Um card reutilizável que exibe uma métrica com um efeito de animação.
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  final Color? color; // Permite customizar a cor do card

  const MetricCard({
    Key? key,
    required this.icon,
    required this.number,
    required this.label,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Determina a cor de fundo e a cor do conteúdo (texto/ícone)
    final cardColor = color ?? cs.surfaceVariant;
    final onCardColor = color == null
        ? cs.onSurfaceVariant
        : (ThemeData.estimateBrightnessForColor(cardColor) == Brightness.dark
        ? Colors.white
        : Colors.black);


    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: Card(
        elevation: 4,
        shadowColor: cs.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: onCardColor),
              const SizedBox(height: 12),
              Text(
                number,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onCardColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: onCardColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uma seção que exibe um título e uma grade responsiva de MetricCards, required String title, required String title.
class IndicadoresSection extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;
  final String title; // <-- O parâmetro que estava faltando

  const IndicadoresSection({
    Key? key,
    required this.title, // <-- Adicionado ao construtor
    required this.metrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics.map((m) {
            return SizedBox(
              width: 150,
              child: MetricCard(
                icon: m['icon'],
                number: m['number'],
                label: m['label'],
                color: m['color'],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
