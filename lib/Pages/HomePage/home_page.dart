import 'package:flutter/material.dart';
import '../AlertaPage/alerta_page.dart';
import '../AtendimentoPage/atendimento_page.dart';
import '../PedidosPage/pedidos_page.dart';
import 'Components/sidebar.dart';

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
      // Nenhuma AppBar aqui
      backgroundColor: Colors.black12, // Usa o gradiente de fundo do Stack
      body: Stack(
        children: [
          // Fundo com gradiente escuro e moderno
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E1E2F), // Roxo escuro azulado
                  Color(0xFF2A2A40), // Azul grafite
                ],
              ),
            ),
          ),
          Row(
            children: [
              // Sidebar retrátil e responsiva
              Sidebar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),

              // Conteúdo principal da página
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
}
