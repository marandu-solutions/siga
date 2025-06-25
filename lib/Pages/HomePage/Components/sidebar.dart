// lib/widgets/sidebar.dart (ou onde seu arquivo estiver)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../Service/auth_service.dart';


// ✅ CONVERTIDO PARA STATELESSWIDGET: Mais simples e performático.
class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // Lista de itens de navegação (nenhuma mudança necessária aqui)
  static const List<Map<String, dynamic>> _navItems = [
    {'icon': LucideIcons.receipt, 'label': 'Pedidos'},
    {'icon': LucideIcons.messageCircle, 'label': 'Atendimento'},
    {'icon': LucideIcons.siren, 'label': 'Alerta'},
    {'icon': LucideIcons.archive, 'label': 'Estoque'}, // Exemplo: Adicionando Estoque
    {'icon': LucideIcons.layoutGrid, 'label': 'Catálogo'},
    {'icon': LucideIcons.star, 'label': 'Feedbacks'},
  ];

  // ✅ MÉTODO DE LOGOUT ATUALIZADO
  void _performLogout(BuildContext context) {
    // Apenas diz ao serviço para deslogar. O AuthWrapper cuidará do resto.
    context.read<AuthService>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // ✅ Usamos um Consumer para "ouvir" o AuthService e reconstruir a UI quando ele mudar.
    return Consumer<AuthService>(
      builder: (context, authService, child) {

        // Se o funcionário ainda não carregou, mostramos um estado de carregamento.
        if (authService.funcionarioLogado == null) {
          return const Drawer(child: Center(child: CircularProgressIndicator()));
        }

        // ✅ Pegamos os dados reativamente do serviço.
        final userName = authService.funcionarioLogado!.nome;
        final userEmail = authService.funcionarioLogado!.email;
        final tt = theme.textTheme;

        return Drawer(
          backgroundColor: cs.surface,
          child: Column(
            children: [
              // 1. HEADER AGORA USA OS DADOS REATIVOS
              UserAccountsDrawerHeader(
                accountName: Text(
                  userName,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
                accountEmail: Text(
                  userEmail,
                  style: tt.bodyMedium?.copyWith(color: cs.onPrimary.withOpacity(0.8)),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: cs.onPrimary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: tt.headlineMedium?.copyWith(color: cs.primary),
                  ),
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                ),
              ),

              // Gera a lista de itens (nenhuma mudança na lógica do loop)
              for (int i = 0; i < _navItems.length; i++)
                _buildNavItem(
                  context: context,
                  icon: _navItems[i]['icon'],
                  title: _navItems[i]['label'],
                  index: i,
                ),

              const Spacer(),

              // 2. BOTÃO SAIR AGORA CHAMA O NOVO MÉTODO DE LOGOUT
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
                  onTap: () => _performLogout(context), // Chama a nova função
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // O método auxiliar agora precisa do BuildContext para acessar o tema.
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;
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
        selected: isSelected,
        selectedTileColor: cs.primaryContainer.withOpacity(0.5),
        selectedColor: cs.primary,
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          onItemSelected(index);
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}