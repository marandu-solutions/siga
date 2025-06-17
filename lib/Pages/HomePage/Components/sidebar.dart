import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  // Mapeamento dos itens de navegação para manter a organização do código original.
  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.receipt_long_outlined, 'label': 'Pedidos'},
    {'icon': Icons.support_agent_rounded, 'label': 'Atendimento'},
    {'icon': Icons.warning_amber_rounded, 'label': 'Alerta'},
    {'icon': Icons.inventory_2_outlined,  'label': 'Catálogo'},
    {'icon': Icons.reviews_outlined,      'label': 'Feedbacks'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 2.0, // Sombra sutil para destacar o Drawer
      child: Column(
        children: [
          // Um CircleAvatar para o perfil do usuário, adaptado ao novo layout.
          const UserAccountsDrawerHeader(
            accountName: Text(
              "Nome do Usuário",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            // A linha accountEmail foi removida daqui.
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.blueAccent,
                size: 40,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ), accountEmail: null,
          ),

          // Gera a lista de itens de navegação dinamicamente
          for (int i = 0; i < _navItems.length; i++)
            _buildNavItem(
              context: context,
              icon: _navItems[i]['icon'],
              title: _navItems[i]['label'],
              index: i,
            ),

          const Spacer(), // Empurra os itens seguintes para o final

          // Divisor e item de Sair
          const Divider(thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
              ),
              hoverColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                // Adicione aqui a sua lógica de logout
                // Exemplo: Navigator.of(context).pushReplacementNamed('/login');
                print('Logout solicitado!');
              },
            ),
          ),
          const SizedBox(height: 10), // Espaço inferior para respiro
        ],
      ),
    );
  }

  /// Método auxiliar para construir cada item de navegação, evitando repetição de código.
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    final selectedColor = theme.primaryColor;

    return Padding(
      // Adiciona padding horizontal e vertical para cada item.
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        selected: isSelected,
        // Cor de fundo quando o item está selecionado.
        selectedTileColor: selectedColor.withOpacity(0.15),
        // Cor do ícone e do texto quando o item está selecionado.
        selectedColor: selectedColor,
        // Cor ao passar o mouse por cima.
        hoverColor: selectedColor.withOpacity(0.1),
        // Bordas arredondadas para um visual moderno.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}