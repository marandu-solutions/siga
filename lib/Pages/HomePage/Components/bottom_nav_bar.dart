// main.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const FloatingNavPage({super.key});

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
    // A altura não é mais necessária aqui, pois a barra tem seu próprio tamanho.
    // O padding pode ser ajustado se necessário.
    const double bottomNavBarHeight = 90.0; // Altura estimada para o padding

    return Scaffold(
      // Você pode adicionar um backgroundColor para ver o contraste da barra flutuante
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Conteúdo principal
          _pages[_currentIndex],

          // Barra flutuante posicionada na parte inferior
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


// --- INÍCIO DA CLASSE REFATORADA ---

/// Uma barra de navegação inferior flutuante, moderna e animada.
///
/// Utiliza o pacote `google_nav_bar` para uma experiência de usuário superior,
/// mantendo o design flutuante graças ao posicionamento na tela principal.
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // Mantemos os dados originais da sua UI
  static const _navItems = [
    {'icon': LucideIcons.package, 'label': 'Pedidos'},
    {'icon': LucideIcons.headphones, 'label': 'Atendimento'},
    {'icon': LucideIcons.alertCircle, 'label': 'Alerta'},
    {'icon': LucideIcons.box, 'label': 'Catálogo'},
    {'icon': LucideIcons.thumbsUp, 'label': 'Feedbacks'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // O Container cria o efeito de "cartão flutuante" com sombra e bordas arredondadas.
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Cor de fundo da barra
        borderRadius: BorderRadius.circular(32), // Bordas bem arredondadas
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.15),
            offset: const Offset(0, 5),
          )
        ],
      ),
      // Clip.antiAlias garante que o conteúdo da GNav respeite as bordas arredondadas.
      clipBehavior: Clip.antiAlias,
      child: Padding(
        // Padding interno para a GNav não ficar colada nas bordas do cartão.
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: GNav(
          // Estilo dos botões e da barra
          rippleColor: theme.primaryColor.withOpacity(0.1),
          hoverColor: theme.primaryColor.withOpacity(0.05),
          gap: 8, // Espaço entre o ícone e o texto quando selecionado
          activeColor: Colors.white, // Cor do ícone e texto ativos
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(milliseconds: 300), // Duração da animação
          tabBackgroundColor: theme.primaryColor, // Cor de fundo do item ativo
          color: theme.colorScheme.onSurface.withOpacity(0.6), // Cor dos ícones inativos

          // Gera as abas (GButton) a partir da nossa lista de dados
          tabs: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            return GButton(
              icon: item['icon'] as IconData,
              text: item['label'] as String,
            );
          }),

          // Controle de estado
          selectedIndex: selectedIndex,
          onTabChange: onItemSelected, // Callback quando uma aba é tocada
        ),
      ),
    );
  }
}
// --- FIM DA CLASSE REFATORADA ---