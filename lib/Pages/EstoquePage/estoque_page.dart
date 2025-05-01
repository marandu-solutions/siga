import 'package:flutter/material.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({Key? key}) : super(key: key);

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final List<Map<String, dynamic>> _itensEstoque = [
    {'nome': 'Camisa Algodão', 'quantidade': 120, 'limite': 50},
    {'nome': 'Camiseta Dri-Fit', 'quantidade': 45, 'limite': 50},
    {'nome': 'Bonés Personalizados', 'quantidade': 30, 'limite': 20},
    {'nome': 'Mochilas', 'quantidade': 8, 'limite': 10},
  ];

  bool _estoqueEmFalta(Map<String, dynamic> item) {
    return item['quantidade'] < item['limite'];
  }

  Future<void> _showItemDialog({int? index}) async {
    final cs = Theme.of(context).colorScheme;
    final isEdit = index != null;
    final item = isEdit ? _itensEstoque[index!] : null;

    final nomeCtrl = TextEditingController(text: item?['nome']);
    final quantidadeCtrl = TextEditingController(text: item?['quantidade']?.toString());
    final limiteCtrl = TextEditingController(text: item?['limite']?.toString());

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: cs.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isEdit ? 'Editar Produto' : 'Novo Produto',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _buildTextField(controller: nomeCtrl, icon: Icons.shopping_bag_outlined, label: 'Nome do produto'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: quantidadeCtrl,
                                icon: Icons.format_list_numbered,
                                label: 'Quantidade',
                                keyboardType: TextInputType.number,
                                validator: (v) => int.tryParse(v ?? '') == null ? 'Número inválido' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: limiteCtrl,
                                icon: Icons.warning_amber_outlined,
                                label: 'Estoque mínimo',
                                keyboardType: TextInputType.number,
                                validator: (v) => int.tryParse(v ?? '') == null ? 'Número inválido' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('Cancelar', style: TextStyle(color: cs.onSurfaceVariant)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final nome = nomeCtrl.text.trim();
                                  final q = int.parse(quantidadeCtrl.text.trim());
                                  final l = int.parse(limiteCtrl.text.trim());
                                  setState(() {
                                    if (isEdit) {
                                      _itensEstoque[index!] = {'nome': nome, 'quantidade': q, 'limite': l};
                                    } else {
                                      _itensEstoque.add({'nome': nome, 'quantidade': q, 'limite': l});
                                    }
                                  });
                                  Navigator.of(ctx).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(isEdit ? 'Salvar' : 'Adicionar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (v) => v!.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estoque',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _itensEstoque.length,
              itemBuilder: (context, index) {
                final item = _itensEstoque[index];
                final emFalta = _estoqueEmFalta(item);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (_) {},
                        side: BorderSide(color: emFalta ? cs.error : cs.primary),
                        fillColor: MaterialStateProperty.all(emFalta ? cs.error : cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nome'], style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              'Em estoque: ${item['quantidade']}   •   Mínimo: ${item['limite']}',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: cs.primary),
                        onPressed: () => _showItemDialog(index: index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: Icon(Icons.add, color: cs.onPrimary),
              label: Text('Adicionar Item'),
              onPressed: () => _showItemDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
