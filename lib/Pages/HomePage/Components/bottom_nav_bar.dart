// lib/components/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import '../../PedidosPage/pedidos_page.dart';
import '../../AtendimentoPage/atendimento_page.dart';
import '../../AlertaPage/alerta_page.dart';
import '../../FeedbackPage/feedback_page.dart';
import '../../EstoquePage/estoque_page.dart';  // Adicionando o import de EstoquePage

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  final List<Widget> pages = const [
    PedidosPage(),
    AtendimentoPage(),
    AlertaPage(),
    FeedbacksPage(),
    EstoquePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E4C), // Cor mais escura no topo
              Color(0xFF2A2A72), // Cor mais clara no fundo
            ],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemSelected,
          selectedItemColor: Colors.white, // Cor do ícone quando selecionado
          unselectedItemColor: Colors.white.withOpacity(0.7), // Cor do ícone quando não selecionado
          backgroundColor: Colors.transparent, // Remover fundo da BottomNavigationBar
          type: BottomNavigationBarType.fixed, // Garantir que todos os itens tenham o mesmo tamanho
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headphones),
              label: 'Atendimento',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback),
              label: 'Feedbacks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Estoque',
            ),
          ],
        ),
      ),
    );
  }
}
