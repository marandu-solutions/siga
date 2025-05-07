// Pages/HomePage/home_page.dart
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../PedidosPage/pedidos_page.dart';
import '../AtendimentoPage/atendimento_page.dart';
import '../AlertaPage/alerta_page.dart';
import '../EstoquePage/estoque_page.dart';
import '../FeedbackPage/feedback_page.dart';
import 'Components/bottom_nav_bar.dart';
import 'Components/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    PedidosPage(),
    AtendimentoPage(),
    AlertaPage(),
    EstoquePage(),
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
        final isMobile = constraints.maxWidth < 600;
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
        } else {
          return Scaffold(
            extendBody: true,
            body: Stack(
              children: [
                Row(
                  children: [
                    Sidebar(
                      selectedIndex: _selectedIndex,
                      onItemSelected: _onItemTapped,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _pages[_selectedIndex],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
