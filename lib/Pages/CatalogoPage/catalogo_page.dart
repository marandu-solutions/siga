import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../Model/catalogo.dart';
import 'package:image_picker/image_picker.dart';
import 'Components/catalogo_card.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  _CatalogoPageState createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _showDeleteConfirmation(BuildContext context, int index, String itemName) async { // <-- Recebe o 'index'
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o item "$itemName"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Excluir'),
            onPressed: () {
              // Chama a sua função original usando o índice
              context.read<CatalogoModel>().remover(index);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showItemDialog(BuildContext context, {int? index}) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEdit = index != null;
    final model = context.read<CatalogoModel>();
    final existing = isEdit ? model.itens[index] : null;

    String? fotoBase64 = existing?.fotoBase64;
    final nomeCtrl = TextEditingController(text: existing?.nome);
    final quantidadeCtrl = TextEditingController(text: existing?.quantidade.toString());
    final precoCtrl = TextEditingController(text: existing?.preco.toString());
    final descricaoCtrl = TextEditingController(text: existing?.descricao);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (ctxDialog, setState) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Editar Produto' : 'Novo Produto',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: fotoBase64 != null
                          ? Image.memory(base64Decode(fotoBase64!), width: 120, height: 120, fit: BoxFit.cover)
                          : Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.camera_alt, size: 40, color: cs.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          final picked = await _picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            final bytes = await picked.readAsBytes();
                            setState(() => fotoBase64 = base64Encode(bytes));
                          }
                        },
                        icon: Icon(Icons.add_a_photo, color: cs.primary),
                        label: Text('Selecionar Foto', style: TextStyle(color: cs.primary)),
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
                              Expanded(child: _buildTextField(controller: quantidadeCtrl, icon: Icons.format_list_numbered, label: 'Quantidade', keyboardType: TextInputType.number, context: context, validator: (v) => int.tryParse(v ?? '') == null ? 'Número inválido' : null)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(controller: precoCtrl, icon: Icons.attach_money, label: 'Preço', keyboardType: const TextInputType.numberWithOptions(decimal: true), context: context, validator: (v) => double.tryParse(v?.replaceAll(',', '.') ?? '') == null ? 'Número inválido' : null)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // CORREÇÃO APLICADA AQUI
                          TextFormField(
                            controller: descricaoCtrl,
                            style: TextStyle(color: cs.onSurface),
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              labelStyle: TextStyle(color: cs.onSurfaceVariant),
                              prefixIcon: Icon(Icons.description_outlined, color: cs.onSurfaceVariant),
                              filled: true,
                              fillColor: cs.surfaceContainerHighest.withOpacity(0.5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ).applyDefaults(theme.inputDecorationTheme),
                            maxLines: 3,
                            validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final newItem = CatalogoItem(
                                nome: nomeCtrl.text.trim(),
                                quantidade: int.parse(quantidadeCtrl.text.trim()),
                                preco: double.parse(precoCtrl.text.replaceAll(',', '.').trim()),
                                descricao: descricaoCtrl.text.trim(),
                                fotoBase64: fotoBase64, empresa: '',
                              );
                              if (isEdit) {
                                model.atualizar(index, newItem);
                              } else {
                                model.adicionar(newItem);
                              }
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: Text(isEdit ? 'Salvar' : 'Adicionar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // CORREÇÃO APLICADA AQUI
  Widget _buildTextField({required TextEditingController controller, required IconData icon, required String label, required BuildContext context, TextInputType? keyboardType, String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return TextFormField(
      controller: controller,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: cs.primary),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ).applyDefaults(theme.inputDecorationTheme),
      keyboardType: keyboardType,
      validator: validator ?? (v) => v!.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Produtos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CatalogoModel>(
        builder: (context, model, _) {
          if (model.itens.isEmpty) return const Center(child: Text('Nenhum item no catálogo.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: model.itens.length,
            itemBuilder: (context, index) {
              final item = model.itens[index];
              return CatalogoCard(
                item: item,
                onTap: () => _showItemDialog(context, index: index),
                onDelete: () => _showDeleteConfirmation(context, index, item.nome),
              );
            },
          );
        },
      ),
    );
  }
}
