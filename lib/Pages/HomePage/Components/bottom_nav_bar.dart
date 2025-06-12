import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nav Flutuante Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FloatingNavPage(),
    );
  }
}

class FloatingNavPage extends StatefulWidget {
  const FloatingNavPage({ Key? key }) : super(key: key);

  @override
  _FloatingNavPageState createState() => _FloatingNavPageState();
}

class _FloatingNavPageState extends State<FloatingNavPage> {
  int _currentIndex = 0;

  final _pages = <Widget>[
    const Center(child: Text('Pedidos')),
    const Center(child: Text('Atendimento')),
    const Center(child: Text('Alerta')),
    const Center(child: Text('Catálogo')),
    const Center(child: Text('Feedbacks')),
  ];

  void _onNavSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Altura estimada da BottomNavBar (para padding do conteúdo)
    final navBarHeight = MediaQuery.of(context).size.width < 350 ? 56.0 : 72.0;

    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo principal com padding para não ficar escondido
          Padding(
            padding: EdgeInsets.only(bottom: navBarHeight + 16),
            child: _pages[_currentIndex],
          ),

          // Barra flutuante
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: BottomNavBar(
              selectedIndex: _currentIndex,
              onItemSelected: _onNavSelected,
            ),
          ),
        ],
      ),
    );
  }
}

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
    _NavItem(icon: LucideIcons.box, label: 'Catálogo'),
    _NavItem(icon: LucideIcons.thumbsUp, label: 'Feedbacks'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 350;

    // Ajustes de padding e altura como você já fez
    final hPad = isCompact ? 8.0 : 12.0;
    final vPad = isCompact ? 10.0 : 12.0;
    final navH = isCompact ? 60.0 : 72.0;

    return Card(
      // Card é a forma ideal de criar um container flutuante
      // que respeita o tema.
      elevation: 10.0, // Elevação pronunciada para o efeito flutuante
      shadowColor: theme.colorScheme.shadow.withOpacity(0.25),
      margin: const EdgeInsets.all(0), // Removemos a margem padrão do Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      // Usamos o surfaceColor do NavigationBarTheme para consistência com o Material 3,
      // ou um fallback para a cor de superfície do tema.
      color: theme.navigationBarTheme.backgroundColor ?? theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias, // Previne que o InkWell vaze
      child: Container(
        height: navH,
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final selected = index == selectedIndex;

            // O _NavButton continua funcionando perfeitamente aqui!
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
    final isDark = theme.brightness == Brightness.dark;
    final baseSize = isCompact ? 18.0 : 22.0;
    final selSize = isCompact ? 22.0 : 26.0;
    final horizPad = isCompact ? 8.0 : 12.0;
    final vertPad = isCompact ? 4.0 : 8.0;

    final selectedBg = theme.colorScheme.primaryContainer.withOpacity(isDark ? 0.5 : 0.3);
    final splashClr = theme.colorScheme.primary.withOpacity(0.3);

    final unselectedColor = theme.colorScheme.onSurface;
    final selectedColor = isDark
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: splashClr,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: horizPad, vertical: vertPad),
          decoration: BoxDecoration(
            color: selected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: selected ? selSize : baseSize,
                color: selected ? selectedColor : unselectedColor,
              ),
              if (selected && !isCompact) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selectedColor,
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
