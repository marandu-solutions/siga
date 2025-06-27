import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:siga/Model/catalogo.dart';
import 'package:siga/Service/auth_service.dart';
import 'package:siga/Service/catalogo_service.dart';
import 'package:siga/Service/storage_service.dart';

// Supondo que o CatalogoCard esteja neste caminho
import 'Components/catalogo_card.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  _CatalogoPageState createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final ImagePicker _picker = ImagePicker();

  // --- LÓGICA DE AÇÕES ATUALIZADA ---

  Future<void> _showDeleteConfirmation(BuildContext context, CatalogoItem item) async {
    final catalogoService = context.read<CatalogoService>();
    
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o item "${item.nome}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Excluir'),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              try {
                await catalogoService.deletarItem(item.id);
                scaffoldMessenger.showSnackBar(SnackBar(content: Text('Item "${item.nome}" excluído.')));
              } catch (e) {
                scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
              }
              navigator.pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showItemDialog(BuildContext context, {CatalogoItem? item}) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEdit = item != null;

    final nomeCtrl = TextEditingController(text: item?.nome);
    final precoCtrl = TextEditingController(text: isEdit ? item!.preco.toStringAsFixed(2) : null);
    final descricaoCtrl = TextEditingController(text: item?.descricao);
    final formKey = GlobalKey<FormState>();

    XFile? pickedImageFile;
    String? existingImageUrl = item?.fotoUrl;
    bool isLoading = false;

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
              builder: (ctxDialog, setStateDialog) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEdit ? 'Editar Produto' : 'Novo Produto', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: pickedImageFile != null
                            ? Image.file(File(pickedImageFile!.path), width: 120, height: 120, fit: BoxFit.cover)
                            : existingImageUrl != null
                                ? Image.network(existingImageUrl!, width: 120, height: 120, fit: BoxFit.cover, 
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                                )
                                : Container(
                                    width: 120, height: 120,
                                    color: cs.surfaceContainerHighest,
                                    child: Icon(Icons.camera_alt, size: 40, color: cs.onSurfaceVariant),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                          if (picked != null) {
                            setStateDialog(() => pickedImageFile = picked);
                          }
                        },
                        icon: Icon(Icons.add_a_photo, color: cs.primary),
                        label: Text(isEdit ? 'Alterar Foto' : 'Selecionar Foto', style: TextStyle(color: cs.primary)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildTextField(controller: nomeCtrl, icon: Icons.shopping_bag_outlined, label: 'Nome do produto', context: context),
                          const SizedBox(height: 16),
                          _buildTextField(controller: precoCtrl, icon: Icons.attach_money, label: 'Preço', keyboardType: const TextInputType.numberWithOptions(decimal: true), context: context, validator: (v) => (double.tryParse(v?.replaceAll(',', '.') ?? '') ?? -1) < 0 ? 'Número inválido' : null),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descricaoCtrl,
                            decoration: const InputDecoration(labelText: 'Descrição', alignLabelWithHint: true, border: OutlineInputBorder()),
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
                          onPressed: isLoading ? null : () async {
                            if (formKey.currentState!.validate()) {
                              setStateDialog(() => isLoading = true);
                              
                              final storageService = context.read<StorageService>();
                              final catalogoService = context.read<CatalogoService>();
                              final authService = context.read<AuthService>();
                              final empresaId = authService.empresaAtual?.id;
                              final funcionario = authService.funcionarioLogado;

                              if(empresaId == null || funcionario == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Sessão inválida. Faça login novamente.')));
                                setStateDialog(() => isLoading = false);
                                return;
                              }
                              
                              String? fotoUrlParaSalvar = existingImageUrl;

                              if(pickedImageFile != null) {
                                fotoUrlParaSalvar = await storageService.uploadFotoCatalogo(file: pickedImageFile!, empresaId: empresaId);
                              }

                              final itemData = CatalogoItem(
                                id: isEdit ? item!.id : '',
                                empresaId: empresaId,
                                nome: nomeCtrl.text.trim(),
                                preco: double.parse(precoCtrl.text.replaceAll(',', '.').trim()),
                                descricao: descricaoCtrl.text.trim(),
                                fotoUrl: fotoUrlParaSalvar,
                                componentesEstoque: isEdit ? item!.componentesEstoque : [],
                                createdAt: isEdit ? item!.createdAt : Timestamp.now(),
                                updatedAt: Timestamp.now(),
                                criadoPor: isEdit ? item!.criadoPor : {'uid': funcionario.uid, 'nome': funcionario.nome},
                              );

                              try {
                                if (isEdit) {
                                  await catalogoService.editarItem(itemData);
                                } else {
                                  await catalogoService.adicionarItem(itemData);
                                }
                                Navigator.of(ctx).pop();
                              } catch(e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
                              } finally {
                                setStateDialog(() => isLoading = false);
                              }
                            }
                          },
                          child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isEdit ? 'Salvar' : 'Adicionar'),
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

  Widget _buildTextField({required TextEditingController controller, required IconData icon, required String label, required BuildContext context, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      keyboardType: keyboardType,
      validator: validator ?? (v) => v!.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final catalogoService = context.read<CatalogoService>();
    final empresaId = authService.empresaAtual?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Produtos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Produto',
      ),
      body: empresaId == null
          ? const Center(child: Text("Carregando dados da empresa..."))
          : StreamBuilder<List<CatalogoItem>>(
              stream: catalogoService.getCatalogoDaEmpresaStream(empresaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erro ao carregar catálogo: ${snapshot.error}"));
                }
                
                final itens = snapshot.data ?? [];

                if (itens.isEmpty) {
                  return const Center(child: Text('Nenhum item no catálogo. Clique em "+" para adicionar o primeiro.'));
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: itens.length,
                  itemBuilder: (context, index) {
                    final item = itens[index];
                    return CatalogoCard(
                      item: item,
                      onTap: () => _showItemDialog(context, item: item),
                      onDelete: () => _showDeleteConfirmation(context, item),
                    );
                  },
                );
              },
            ),
    );
  }
}