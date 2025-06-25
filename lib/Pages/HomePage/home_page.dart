// Pages/HomePage/home_page.dart
import 'package:flutter/material.dart';

import '../PedidosPage/pedidos_page.dart';
import '../AtendimentoPage/atendimento_page.dart';
import '../AlertaPage/alerta_page.dart';
import '../CatalogoPage/catalogo_page.dart';
import '../FeedbackPage/feedback_page.dart';
import 'Components/bottom_nav_bar.dart';
import 'Components/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    PedidosPage(),
    AtendimentoPage(),
    AlertaPage(),
    CatalogoPage(),
    FeedbacksPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 1000;
        if (isMobile) {
          return Scaffold(
            extendBody: true,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 75.0), // ajuste o valor conforme o tamanho da nav bar
              child: _pages[_selectedIndex],
            ),
            bottomNavigationBar: BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        } return Scaffold(
          body: Row(
            children: [
              Sidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: _onItemTapped,
              ),
              Expanded(
                // Usamos um padding ao redor da área do conteúdo principal
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                  child: Card(
                    // O widget Card já usa cores do tema (surface) e tem uma elevação sutil
                    elevation: 8.0, // Aumenta a percepção de profundidade
                    shadowColor: Colors.black.withOpacity(0.3), // Sombra mais intencional
                    clipBehavior: Clip.antiAlias, // Garante que o conteúdo não vaze das bordas arredondadas
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      // Adicionamos uma borda sutil que usa a cor 'outline' do tema
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: _pages[_selectedIndex],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
