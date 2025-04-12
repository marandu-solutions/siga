import 'package:flutter/material.dart';
import '../AlertaPage/alerta_page.dart';
import '../AtendimentoPage/atendimento_page.dart';
import '../PedidosPage/pedidos_page.dart';
import 'Components/sidebar.dart'; // Importando o Sidebar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const PedidosPage(),
    const AtendimentoPage(),
    AlertaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A74DA), Color(0xFF74C0FC)],
              ),
            ),
          ),
          Row(
            children: [
              Sidebar(
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: pages[selectedIndex],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
