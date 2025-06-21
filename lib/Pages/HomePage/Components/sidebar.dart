import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Usando Lucide para consistência
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
  String _userName = 'Carregando...';
  String _userEmail = '';

  // Lista de itens de navegação com ícones Lucide para um visual mais moderno.
  static const List<Map<String, dynamic>> _navItems = [
    {'icon': LucideIcons.receipt, 'label': 'Pedidos'},
    {'icon': LucideIcons.messageCircle, 'label': 'Atendimento'},
    {'icon': LucideIcons.siren, 'label': 'Alerta'},
    {'icon': LucideIcons.layoutGrid, 'label': 'Catálogo'},
    {'icon': LucideIcons.star, 'label': 'Feedbacks'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await AuthService.getUserName();
    final email = await AuthService.getUserEmail();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuário';
        _userEmail = email ?? 'Email não informado';
      });
    }
  }

  void _performLogout(BuildContext context) {
    AuthService.logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Drawer(
      // Usando a cor de fundo do tema para o Drawer
      backgroundColor: cs.surface,
      child: Column(
        children: [
          // 1. HEADER CORRIGIDO PARA USAR AS CORES DO TEMA
          UserAccountsDrawerHeader(
            accountName: Text(
              _userName,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onPrimary, // Texto legível sobre o fundo primário
              ),
            ),
            accountEmail: Text(
              _userEmail,
              style: tt.bodyMedium?.copyWith(color: cs.onPrimary.withOpacity(0.8)),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: cs.onPrimary,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: tt.headlineMedium?.copyWith(color: cs.primary),
              ),
            ),
            decoration: BoxDecoration(
              color: cs.primary, // Usa a cor primária do seu tema
            ),
          ),

          // Gera a lista de itens de navegação dinamicamente
          for (int i = 0; i < _navItems.length; i++)
            _buildNavItem(
              icon: _navItems[i]['icon'],
              title: _navItems[i]['label'],
              index: i,
            ),

          const Spacer(),

          // 2. BOTÃO SAIR CORRIGIDO PARA USAR A COR DE ERRO DO TEMA
          const Divider(thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(LucideIcons.logOut, color: cs.error),
              title: Text(
                'Sair',
                style: tt.labelLarge?.copyWith(color: cs.error, fontWeight: FontWeight.bold),
              ),
              hoverColor: cs.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                // A verificação se o drawer está aberto garante que só será fechado no mobile.
                if (Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context);
                }
                _performLogout(context);
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Método auxiliar para construir cada item de navegação com cores do tema.
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = widget.selectedIndex == index;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        // Usando as propriedades do ListTile para um comportamento correto
        selected: isSelected,
        selectedTileColor: cs.primary.withOpacity(0.1),
        selectedColor: cs.primary, // Cor para texto e ícone quando selecionado
        iconColor: cs.onSurfaceVariant, // Cor padrão do ícone
        textColor: cs.onSurface, // Cor padrão do texto
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          widget.onItemSelected(index);
          // CORREÇÃO: Só fecha o menu se ele for um "Drawer" (no mobile).
          // No desktop, onde ele é fixo, não faz nada.
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
