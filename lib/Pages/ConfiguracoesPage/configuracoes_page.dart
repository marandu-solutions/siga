import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../Model/empresa.dart';
import '../../../Model/funcionario.dart';
import 'Components/funcionario_card.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Estado de exemplo para a UI
  bool _lojaAberta = true;
  // Usando seu modelo Funcionario para os dados de exemplo
  final List<Funcionario> _funcionarios = [
    Funcionario(uid: '1', empresaId: 'emp1', nome: 'Ana Silva (Gerente)', email: 'ana.silva@email.com', cargo: 'admin', ativo: true),
    Funcionario(uid: '2', empresaId: 'emp1', nome: 'Bruno Costa', email: 'bruno.costa@email.com', cargo: 'operador', ativo: true),
    Funcionario(uid: '3', empresaId: 'emp1', nome: 'Carla Dias', email: 'carla.dias@email.com', cargo: 'operador', ativo: false),
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
            subtitle: Text(_lojaAberta ? "Sua loja está aberta e recebendo pedidos." : "Sua loja está fechada e não recebe pedidos."),
            value: _lojaAberta,
            onChanged: (bool value) {
              setState(() => _lojaAberta = value);
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
        const SizedBox(height: 24),
        _buildSectionTitle(context, "Informações Gerais"),
        const SizedBox(height: 12),
        // Lista de opções de configuração
        _buildConfigOption(
          context,
          icon: LucideIcons.building2,
          title: "Perfil da Empresa",
          subtitle: "Edite nome, endereço, logo e dados fiscais.",
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
          subtitle: "Personalize nome e mensagens do seu assistente.",
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
          return FuncionarioCard(funcionario: funcionario);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* Abrir diálogo/página para adicionar novo funcionário */ },
        tooltip: 'Convidar Novo Funcionário',
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

