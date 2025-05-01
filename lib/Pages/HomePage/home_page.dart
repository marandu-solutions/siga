import 'package:flutter/material.dart';
import '../PedidosPage/pedidos_page.dart';
import '../AtendimentoPage/atendimento_page.dart';
import '../AlertaPage/alerta_page.dart';
import '../FeedbackPage/feedback_page.dart';
import '../EstoquePage/estoque_page.dart';
import 'Components/bottom_nav_bar.dart';
import 'Components/sidebar.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    PedidosPage(),
    AtendimentoPage(),
    AlertaPage(),
    FeedbacksPage(),
    EstoquePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileView = constraints.maxWidth < 600;

        if (isMobileView) {
          // Modo mobile: usa BottomNavBar em vez de Drawer
          return BottomNavBar(
            selectedIndex: selectedIndex,
            onItemSelected: (idx) => setState(() => selectedIndex = idx),
          );
        } else {
          // Modo desktop/tablet com sidebar fixa
          return Scaffold(
            backgroundColor: Colors.black12,
            body: Stack(
              children: [
                // Fundo com gradiente
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E1E2F),
                        Color(0xFF2A2A40),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Sidebar(
                      selectedIndex: selectedIndex,
                      onItemSelected: (index) {
                        setState(() => selectedIndex = index);
                      },
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
                            child: pages[selectedIndex],
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
