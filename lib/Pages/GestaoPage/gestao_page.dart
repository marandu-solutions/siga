import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:siga/Pages/AlertaPage/alerta_page.dart';
import 'package:siga/Pages/CatalogoPage/catalogo_page.dart';
import 'package:siga/Pages/CustosPage/Custos_page.dart';
import 'package:siga/Pages/EstoquePage/estoque_page.dart';

import '../FeedbackPage/feedback_page.dart';

// Este é um widget de página completo e autônomo.
// Você pode adicioná-lo à sua lista de páginas na HomePage.

// ===================================================================
// =================== PÁGINA PRINCIPAL DE GESTÃO ===================
// ===================================================================

class GestaoPage extends StatelessWidget {
  const GestaoPage({super.key});

  // Função de placeholder para simular a navegação
  void _navigateTo(BuildContext context, String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando para $pageName...')),
    );
    // No app real, você usaria seu sistema de roteamento.
    // Ex: Navigator.push(context, MaterialPageRoute(builder: (_) => SuaPagina()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text("Gestão do Negócio"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // --- Seção de Produtos e Estoque ---
          _buildSectionTitle(context, "Produtos e Custos"),
          const SizedBox(height: 8),
          _buildManagementOption(
            context,
            icon: LucideIcons.layoutGrid,
            title: "Catálogo de Produtos",
            subtitle: "Gerencie os produtos que você vende.",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CatalogoPage()),
            ),
          ),
          _buildManagementOption(
            context,
            icon: LucideIcons.archive,
            title: "Controle de Estoque",
            subtitle: "Administre sua matéria-prima e insumos.",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EstoquePage()),
            ),
          ),
          _buildManagementOption(
            context,
            icon: LucideIcons.dollarSign,
            title: "Centro de Custos",
            subtitle: "Cadastre despesas fixas e variáveis.",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CentroDeCustosPage()),
            ),
          ),
          const Divider(height: 40),

          // --- Seção de Análise e Crescimento ---
          _buildSectionTitle(context, "Análise e Crescimento"),
          const SizedBox(height: 8),
          _buildManagementOption(
            context,
            icon: LucideIcons.lineChart,
            title: "Relatórios e Feedbacks",
            subtitle: "Analise o desempenho de vendas e a satisfação.",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbacksPage()),
            ),
          ),
          _buildManagementOption(
            context,
            icon: LucideIcons.megaphone,
            title: "Marketing e Campanhas",
            subtitle: "Envie promoções e comunicados via WhatsApp.",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlertaPage()),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um título de seção padronizado.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Constrói um item de menu clicável e estilizado.
  Widget _buildManagementOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
