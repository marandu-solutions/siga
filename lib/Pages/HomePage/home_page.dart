import 'package:flutter/material.dart';
import '../PedidosPage/pedidos_page.dart';
import '../AtendimentoPage/atendimento_page.dart';
import '../AlertaPage/alerta_page.dart';
import '../FeedbackPage/feedback_page.dart';
import '../EstoquePage/estoque_page.dart';       // <-- import adicionado
import 'Components/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> pages = [
    const PedidosPage(),
    const AtendimentoPage(),
    const AlertaPage(),
    FeedbacksPage(),
    const EstoquePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Defina aqui o seu breakpoint (por exemplo, 600px)
        final isMobileView = constraints.maxWidth < 600;

        if (isMobileView) {
          // Modo "hamburger menu"
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                'MARANDU',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
            drawer: Drawer(
              child: Sidebar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() => selectedIndex = index);
                  Navigator.of(context).pop(); // fecha a drawer
                },
              ),
            ),
            body: Container(
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
              child: pages[selectedIndex],
            ),
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
