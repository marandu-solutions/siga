import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/estoque_model.dart';
import '../../Model/estoque.dart';

class EstoquePage extends StatelessWidget {
  const EstoquePage({Key? key}) : super(key: key);

  bool _estoqueEmFalta(EstoqueItem item) {
    return item.quantidade < item.limite;
  }

  Future<void> _showItemDialog(BuildContext context, {int? index}) async {
    final cs = Theme.of(context).colorScheme;
    final isEdit = index != null;
    final model = context.read<EstoqueModel>();
    final item = isEdit ? model.itens[index!] : null;

    final nomeCtrl = TextEditingController(text: item?.nome);
    final quantidadeCtrl = TextEditingController(text: item?.quantidade.toString());
    final limiteCtrl = TextEditingController(text: item?.limite.toString());

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
                        _buildTextField(controller: nomeCtrl, icon: Icons.shopping_bag_outlined, label: 'Nome do produto', context: context),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: quantidadeCtrl,
                                icon: Icons.format_list_numbered,
                                label: 'Quantidade',
                                keyboardType: TextInputType.number,
                                context: context,
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
                                context: context,
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
                                  final novoItem = EstoqueItem(
                                    nome: nomeCtrl.text.trim(),
                                    quantidade: int.parse(quantidadeCtrl.text.trim()),
                                    limite: int.parse(limiteCtrl.text.trim()),
                                  );
                                  if (isEdit) {
                                    model.atualizar(index!, novoItem);
                                  } else {
                                    model.adicionar(novoItem);
                                  }
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
    required BuildContext context,
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
    return Consumer<EstoqueModel>(
      builder: (context, model, _) {
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
                  itemCount: model.itens.length,
                  itemBuilder: (context, index) {
                    final item = model.itens[index];
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
                                Text(item.nome, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  'Em estoque: ${item.quantidade}   •   Mínimo: ${item.limite}',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: cs.primary),
                            onPressed: () => _showItemDialog(context, index: index),
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
                  onPressed: () => _showItemDialog(context),
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
      },
    );
  }
}