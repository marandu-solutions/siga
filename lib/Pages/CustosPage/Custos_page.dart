import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

// Este é um widget de página completo e autônomo.
// Você pode adicioná-lo ao menu da sua tela de "Gestão".

// Modelo de exemplo para os dados de custos.
class Custo {
  final String id;
  final String descricao;
  final double valor;
  final String tipo; // "Fixo" ou "Variavel"

  Custo({required this.id, required this.descricao, required this.valor, required this.tipo});
}

// ===================================================================
// =================== PÁGINA DE CENTRO DE CUSTOS ===================
// ===================================================================

class CentroDeCustosPage extends StatefulWidget {
  const CentroDeCustosPage({super.key});

  @override
  State<CentroDeCustosPage> createState() => _CentroDeCustosPageState();
}

class _CentroDeCustosPageState extends State<CentroDeCustosPage> {
  // Dados de exemplo para a UI.
  final List<Custo> _custos = [
    Custo(id: '1', descricao: 'Aluguel do Espaço', valor: 2500.00, tipo: 'Fixo'),
    Custo(id: '2', descricao: 'Salário - Funcionário A', valor: 1800.00, tipo: 'Fixo'),
    Custo(id: '3', descricao: 'Conta de Energia Elétrica', valor: 450.50, tipo: 'Variavel'),
    Custo(id: '4', descricao: 'Conta de Água', valor: 120.75, tipo: 'Variavel'),
    Custo(id: '5', descricao: 'Internet', valor: 150.00, tipo: 'Fixo'),
  ];

  // Função para abrir o diálogo de adicionar/editar custo.
  void _showAddCustoDialog({Custo? custo}) {
    showDialog(
      context: context,
      builder: (context) {
        return _AddCustoDialog(
          custo: custo,
          onSave: (novoCusto) {
            setState(() {
              if (custo == null) {
                _custos.add(novoCusto);
              } else {
                final index = _custos.indexWhere((c) => c.id == custo.id);
                if (index != -1) {
                  _custos[index] = novoCusto;
                }
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final custosFixos = _custos.where((c) => c.tipo == 'Fixo').toList();
    final custosVariaveis = _custos.where((c) => c.tipo == 'Variavel').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Centro de Custos"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, "Custos Fixos Mensais"),
          const SizedBox(height: 8),
          ...custosFixos.map((custo) => _CustoCard(
            custo: custo,
            onTap: () => _showAddCustoDialog(custo: custo),
            onDelete: () => setState(() => _custos.removeWhere((c) => c.id == custo.id)),
          )),
          const Divider(height: 40),
          _buildSectionTitle(context, "Custos Variáveis (Último Mês)"),
          const SizedBox(height: 8),
          ...custosVariaveis.map((custo) => _CustoCard(
            custo: custo,
            onTap: () => _showAddCustoDialog(custo: custo),
            onDelete: () => setState(() => _custos.removeWhere((c) => c.id == custo.id)),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustoDialog(),
        tooltip: 'Adicionar Custo',
        child: const Icon(Icons.add),
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
}

// ===================================================================
// ================= COMPONENTES DA PÁGINA DE CUSTOS ================
// ===================================================================

/// Card para exibir um único custo.
class _CustoCard extends StatelessWidget {
  final Custo custo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustoCard({required this.custo, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          custo.tipo == 'Fixo' ? LucideIcons.receipt : LucideIcons.fileBarChart2,
          color: theme.colorScheme.secondary,
        ),
        title: Text(custo.descricao, style: theme.textTheme.titleSmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currencyFormatter.format(custo.valor),
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') onTap();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo para adicionar ou editar um custo.
class _AddCustoDialog extends StatefulWidget {
  final Custo? custo;
  final Function(Custo) onSave;

  const _AddCustoDialog({this.custo, required this.onSave});

  @override
  _AddCustoDialogState createState() => _AddCustoDialogState();
}

class _AddCustoDialogState extends State<_AddCustoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  String _tipo = 'Fixo';

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.custo?.descricao ?? '');
    _valorController = TextEditingController(text: widget.custo?.valor.toString() ?? '');
    _tipo = widget.custo?.tipo ?? 'Fixo';
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final novoCusto = Custo(
        id: widget.custo?.id ?? UniqueKey().toString(),
        descricao: _descricaoController.text,
        valor: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
        tipo: _tipo,
      );
      widget.onSave(novoCusto);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.custo == null ? 'Adicionar Custo' : 'Editar Custo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição do Custo'),
              validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(labelText: 'Valor Mensal (R\$)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (double.tryParse(v!.replaceAll(',', '.')) ?? 0) <= 0 ? 'Inválido' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo de Custo'),
              items: ['Fixo', 'Variavel'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _tipo = newValue!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _handleSave, child: const Text('Salvar')),
      ],
    );
  }
}
