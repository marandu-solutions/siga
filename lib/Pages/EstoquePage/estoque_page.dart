import 'package:flutter/material.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({Key? key}) : super(key: key);

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final List<Map<String, dynamic>> itensEstoque = [
    {'nome': 'Camisa Algodão', 'quantidade': 120, 'limite': 50},
    {'nome': 'Camiseta Dri-Fit', 'quantidade': 45, 'limite': 50},
    {'nome': 'Bonés Personalizados', 'quantidade': 30, 'limite': 20},
    {'nome': 'Mochilas', 'quantidade': 8, 'limite': 10},
  ];

  final _formKey = GlobalKey<FormState>();

  Future<void> _showItemDialog({int? index}) async {
    final isEdit = index != null;
    final item = isEdit ? itensEstoque[index!] : null;
    final nomeCtrl = TextEditingController(text: item?['nome'] ?? '');
    final quantidadeCtrl = TextEditingController(text: item?['quantidade']?.toString() ?? '');
    final limiteCtrl = TextEditingController(text: item?['limite']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1E1B2D),
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
                      color: const Color(0xFF2A273C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isEdit ? 'Editar Produto' : 'Novo Produto',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nomeCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Nome do produto',
                            labelStyle: TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.shopping_bag_outlined, color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF2A273C),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? 'Digite um nome' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: quantidadeCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Quantidade',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.white70),
                                  filled: true,
                                  fillColor: const Color(0xFF2A273C),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) => (int.tryParse(v ?? '') == null)
                                    ? 'Número inválido'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: limiteCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Estoque mínimo',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.warning_amber_outlined, color: Colors.white70),
                                  filled: true,
                                  fillColor: const Color(0xFF2A273C),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) => (int.tryParse(v ?? '') == null)
                                    ? 'Número inválido'
                                    : null,
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
                              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final nome = nomeCtrl.text.trim();
                                  final q = int.parse(quantidadeCtrl.text.trim());
                                  final l = int.parse(limiteCtrl.text.trim());
                                  setState(() {
                                    if (isEdit) {
                                      itensEstoque[index!] = {
                                        'nome': nome,
                                        'quantidade': q,
                                        'limite': l,
                                      };
                                    } else {
                                      itensEstoque.add({
                                        'nome': nome,
                                        'quantidade': q,
                                        'limite': l,
                                      });
                                    }
                                  });
                                  Navigator.of(ctx).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5DD3),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estoque',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: itensEstoque.length,
              itemBuilder: (context, index) {
                final item = itensEstoque[index];
                final emFalta = item['quantidade'] < item['limite'];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A273C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (_) {},
                        side: BorderSide(color: emFalta ? Colors.redAccent : Colors.green),
                        fillColor: MaterialStateProperty.all(
                            emFalta ? Colors.redAccent : Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nome'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Em estoque: ${item['quantidade']}   •   Mínimo: ${item['limite']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF6C5DD3)),
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
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Item'),
              onPressed: () => _showItemDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5DD3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
