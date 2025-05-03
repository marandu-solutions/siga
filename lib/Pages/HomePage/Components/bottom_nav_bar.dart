import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../AlertaPage/alerta_page.dart';
import '../../AtendimentoPage/atendimento_page.dart';
import '../../EstoquePage/estoque_page.dart';
import '../../FeedbackPage/feedback_page.dart';
import '../../PedidosPage/pedidos_page.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  static const _navItems = <_NavItem>[
    _NavItem(icon: LucideIcons.package, label: 'Pedidos'),
    _NavItem(icon: LucideIcons.headphones, label: 'Atendimento'),
    _NavItem(icon: LucideIcons.alertCircle, label: 'Alerta'),
    _NavItem(icon: LucideIcons.box, label: 'Estoque'),
    _NavItem(icon: LucideIcons.messageCircle, label: 'Feedbacks'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final isDark   = theme.brightness == Brightness.dark;
    final width    = MediaQuery.of(context).size.width;
    final isCompact = width < 350;

    final hPad = isCompact ? 6.0 : 10.0;
    final vPad = isCompact ? 2.0 : 6.0;
    final navH  = isCompact ? 56.0 : 72.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: navH,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item     = _navItems[index];
                final selected = index == selectedIndex;
                return _NavButton(
                  icon: item.icon,
                  label: item.label,
                  selected: selected,
                  isCompact: isCompact,
                  onTap: () => onItemSelected(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isCompact;
  final VoidCallback onTap;

  const _NavButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.isCompact,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseSize = isCompact ? 16.0 : 20.0;
    final selSize = isCompact ? 20.0 : 24.0;
    final horizPad = isCompact ? 6.0 : 10.0;
    final vertPad = isCompact ? 2.0 : 6.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: theme.colorScheme.primary.withOpacity(0.2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: horizPad,
            vertical: vertPad,
          ),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: selected ? selSize : baseSize,
                color: selected ? theme.colorScheme.primary : theme.iconTheme.color,
              ),
              if (selected && !isCompact) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}