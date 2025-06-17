import 'package:flutter/material.dart';

import '../../../Service/auth_service.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // Variáveis de estado para guardar os dados do usuário.
  String _userName = 'Carregando...';
  String _userEmail = '';

  // Lista de itens de navegação.
  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.receipt_long_outlined, 'label': 'Pedidos'},
    {'icon': Icons.support_agent_rounded, 'label': 'Atendimento'},
    {'icon': Icons.warning_amber_rounded, 'label': 'Alerta'},
    {'icon': Icons.inventory_2_outlined, 'label': 'Catálogo'},
    {'icon': Icons.reviews_outlined, 'label': 'Feedbacks'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carrega os dados do usuário a partir do token JWT usando o AuthService.
  Future<void> _loadUserData() async {
    // Busca o nome e o email do token de forma assíncrona.
    final name = await AuthService.getUserName();
    final email = await AuthService.getUserEmail();

    // Garante que o widget ainda está na tela antes de atualizar o estado.
    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuário';
        _userEmail = email ?? 'Email não informado';
      });
    }
  }

  /// Executa o processo de logout de maneira segura.
  void _performLogout(BuildContext context) {
    // Passo 1: Fecha o Drawer. Essencial para liberar o contexto de navegação.
    Navigator.of(context).pop();

    // Passo 2: Limpa os dados de autenticação do armazenamento.
    AuthService.logout();

    // Passo 3: Redireciona para a tela de login, removendo todas as telas anteriores.
    // Garante que o usuário não possa "voltar" para a tela principal.
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 2.0,
      child: Column(
        children: [
          // Header que exibe os dados do usuário carregados.
          UserAccountsDrawerHeader(
            accountName: Text(
              _userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(_userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.blueAccent,
                size: 40,
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),

          // Gera a lista de itens de navegação dinamicamente.
          for (int i = 0; i < _navItems.length; i++)
            _buildNavItem(
              context: context,
              icon: _navItems[i]['icon'],
              title: _navItems[i]['label'],
              index: i,
            ),

          // Empurra o item de sair para o final da tela.
          const Spacer(),

          // Divisor e item de Sair com a função de logout funcional.
          const Divider(thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text(
                'Sair',
                style:
                TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
              ),
              hoverColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => _performLogout(context), // Chama a função de logout corrigida.
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Método auxiliar para construir cada item de navegação.
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = widget.selectedIndex == index;
    final theme = Theme.of(context);
    final selectedColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        selected: isSelected,
        selectedTileColor: selectedColor.withOpacity(0.15),
        selectedColor: selectedColor,
        hoverColor: selectedColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => widget.onItemSelected(index),
      ),
    );
  }
}