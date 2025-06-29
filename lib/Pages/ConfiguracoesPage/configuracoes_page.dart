import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Este é um widget de página completo e autônomo.
// Você pode adicioná-lo à sua lista de páginas na HomePage.

// Modelo de exemplo para funcionário. No app real, você usaria seu model.
class FuncionarioMock {
  final String id;
  final String nome;
  final String email;
  final String cargo;
  FuncionarioMock({required this.id, required this.nome, required this.email, required this.cargo});
}

// ===================================================================
// =================== PÁGINA PRINCIPAL DE CONFIGURAÇÕES =================
// ===================================================================

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Estado de exemplo para a UI
  bool _lojaAberta = true;
  final List<FuncionarioMock> _funcionarios = [
    FuncionarioMock(id: '1', nome: 'Ana Silva', email: 'ana.silva@email.com', cargo: 'Gerente'),
    FuncionarioMock(id: '2', nome: 'Bruno Costa', email: 'bruno.costa@email.com', cargo: 'Atendente'),
    FuncionarioMock(id: '3', nome: 'Carla Dias', email: 'carla.dias@email.com', cargo: 'Atendente'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text("Configurações"),
        // A TabBar fica na parte de baixo da AppBar
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(LucideIcons.store), text: 'Loja'),
            Tab(icon: Icon(LucideIcons.users), text: 'Equipe'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabLoja(context),
          _buildTabEquipe(context),
        ],
      ),
    );
  }

  // --- ABA DE CONFIGURAÇÕES DA LOJA ---
  Widget _buildTabLoja(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Card para Status da Loja
        Card(
          elevation: 2,
          child: SwitchListTile(
            title: Text(
              "Status da Loja",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_lojaAberta ? "Sua loja está aberta e recebendo pedidos." : "Sua loja está fechada."),
            value: _lojaAberta,
            onChanged: (bool value) {
              setState(() {
                _lojaAberta = value;
              });
              // Aqui você chamaria seu serviço para atualizar o status no backend
            },
            secondary: Icon(
              _lojaAberta ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
              color: _lojaAberta ? cs.secondary : cs.error,
              size: 32,
            ),
            activeColor: cs.secondary,
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle(context, "Informações Gerais"),
        const SizedBox(height: 12),
        // Lista de opções de configuração
        _buildConfigOption(
          context,
          icon: LucideIcons.building2,
          title: "Perfil da Empresa",
          subtitle: "Edite nome, endereço e logo da sua loja.",
          onTap: () { /* Navegar para a página de edição de perfil */ },
        ),
        _buildConfigOption(
          context,
          icon: LucideIcons.clock,
          title: "Horário de Funcionamento",
          subtitle: "Defina os horários de atendimento de cada dia.",
          onTap: () { /* Navegar para a página de edição de horários */ },
        ),
        _buildConfigOption(
          context,
          icon: LucideIcons.bot,
          title: "Configurações da IA",
          subtitle: "Personalize o nome e as mensagens do seu assistente.",
          onTap: () { /* Navegar para a página de config da IA */ },
        ),
      ],
    );
  }

  // --- ABA DE GESTÃO DE EQUIPE ---
  Widget _buildTabEquipe(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _funcionarios.length,
        itemBuilder: (context, index) {
          final funcionario = _funcionarios[index];
          return _FuncionarioCard(funcionario: funcionario);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* Abrir diálogo/página para adicionar novo funcionário */ },
        tooltip: 'Adicionar Funcionário',
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
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

  Widget _buildConfigOption(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}


// --- COMPONENTE PARA O CARD DE FUNCIONÁRIO ---
class _FuncionarioCard extends StatelessWidget {
  final FuncionarioMock funcionario;
  const _FuncionarioCard({required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Text(funcionario.nome.isNotEmpty ? funcionario.nome[0] : '?'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(funcionario.nome, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(funcionario.email, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                funcionario.cargo,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) { /* Lógica para editar/desativar */ },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'deactivate', child: Text('Desativar', style: TextStyle(color: Colors.red))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
