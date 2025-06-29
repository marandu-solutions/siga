import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Este é um widget completo e autônomo. Para usá-lo, você o adicionaria
// ao menu da sua tela de "Gestão".

// Modelo de exemplo para os dados de estoque.
// No seu projeto real, você usaria o seu modelo vindo do Firebase.
class EstoqueItem {
  final String id;
  final String nome;
  double quantidade;
  final String unidade; // Ex: "kg", "L", "un"
  final double nivelAlerta; // Quando a quantidade está abaixo disso, alerta.

  EstoqueItem({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.nivelAlerta,
  });
}

// ===================================================================
// =================== PÁGINA PRINCIPAL DE ESTOQUE ===================
// ===================================================================

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  // Dados de exemplo para a UI.
  final List<EstoqueItem> _itensEstoque = [
    EstoqueItem(id: '1', nome: 'Farinha de Trigo', quantidade: 15.5, unidade: 'kg', nivelAlerta: 5.0),
    EstoqueItem(id: '2', nome: 'Queijo Muçarela', quantidade: 3.2, unidade: 'kg', nivelAlerta: 5.0),
    EstoqueItem(id: '3', nome: 'Tomate', quantidade: 20.0, unidade: 'un', nivelAlerta: 10.0),
    EstoqueItem(id: '4', nome: 'Carne Moída', quantidade: 1.8, unidade: 'kg', nivelAlerta: 2.0),
    EstoqueItem(id: '5', nome: 'Refrigerante 2L', quantidade: 30.0, unidade: 'un', nivelAlerta: 12.0),
  ];

  // Função para abrir o diálogo de adicionar/editar item.
  void _showAddItemDialog({EstoqueItem? item}) {
    showDialog(
      context: context,
      builder: (context) {
        return _AddEstoqueItemDialog(
          item: item,
          onSave: (novoItem) {
            setState(() {
              if (item == null) {
                // Adiciona novo item
                _itensEstoque.add(novoItem);
              } else {
                // Atualiza item existente
                final index = _itensEstoque.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  _itensEstoque[index] = novoItem;
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
    // Ordena a lista para mostrar itens com alerta de estoque baixo primeiro.
    _itensEstoque.sort((a, b) {
      bool aAlerta = a.quantidade <= a.nivelAlerta;
      bool bAlerta = b.quantidade <= b.nivelAlerta;
      if (aAlerta && !bAlerta) return -1;
      if (!aAlerta && bAlerta) return 1;
      return a.nome.compareTo(b.nome);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle de Estoque"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Barra de busca e filtros
          TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar insumo...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          // Lista de itens do estoque
          ..._itensEstoque.map((item) {
            return _EstoqueCard(
              item: item,
              onTap: () => _showAddItemDialog(item: item),
              onDelete: () {
                setState(() {
                  _itensEstoque.removeWhere((i) => i.id == item.id);
                });
              },
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        tooltip: 'Adicionar Insumo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===================================================================
// ================= COMPONENTES DA PÁGINA DE ESTOQUE ================
// ===================================================================

/// Card para exibir um único item do estoque.
class _EstoqueCard extends StatelessWidget {
  final EstoqueItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EstoqueCard({required this.item, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool emAlerta = item.quantidade <= item.nivelAlerta;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // A borda muda de cor se o estoque estiver baixo
        side: BorderSide(
          color: emAlerta ? cs.error.withOpacity(0.7) : cs.outline.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícone que indica o status do estoque
              Icon(
                emAlerta ? LucideIcons.alertTriangle : LucideIcons.package,
                color: emAlerta ? cs.error : cs.primary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estoque: ${item.quantidade.toStringAsFixed(2)} ${item.unidade}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Menu de Ações (Editar, Excluir)
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
      ),
    );
  }
}

class _AddEstoqueItemDialog extends StatefulWidget {
  final EstoqueItem? item;
  final Function(EstoqueItem) onSave;

  const _AddEstoqueItemDialog({this.item, required this.onSave});

  @override
  _AddEstoqueItemDialogState createState() => _AddEstoqueItemDialogState();
}

class _AddEstoqueItemDialogState extends State<_AddEstoqueItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _quantidadeController;
  late TextEditingController _alertaController;
  String _unidade = 'un';

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item?.nome ?? '');
    _quantidadeController = TextEditingController(text: widget.item?.quantidade.toString() ?? '');
    _alertaController = TextEditingController(text: widget.item?.nivelAlerta.toString() ?? '');
    _unidade = widget.item?.unidade ?? 'un';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _alertaController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final novoItem = EstoqueItem(
        id: widget.item?.id ?? UniqueKey().toString(),
        nome: _nomeController.text,
        quantidade: double.tryParse(_quantidadeController.text) ?? 0.0,
        unidade: _unidade,
        nivelAlerta: double.tryParse(_alertaController.text) ?? 0.0,
      );
      widget.onSave(novoItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Adicionar Insumo' : 'Editar Insumo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Insumo'),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(labelText: 'Quantidade Atual'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (double.tryParse(v!) ?? -1) < 0 ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _unidade,
                    items: ['un', 'kg', 'g', 'L', 'ml'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _unidade = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alertaController,
                decoration: const InputDecoration(labelText: 'Nível de Alerta de Estoque Baixo'),
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse(v!) ?? -1) < 0 ? 'Inválido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _handleSave, child: const Text('Salvar')),
      ],
    );
  }
}
