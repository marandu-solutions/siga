import 'package:flutter/material.dart';

import '../../../Model/custos.dart';

class AddCustoDialog extends StatefulWidget {
  final Custo? custo;
  final Function(Custo) onSave;

  const AddCustoDialog({this.custo, required this.onSave});

  @override
  AddCustoDialogState createState() => AddCustoDialogState();
}

class AddCustoDialogState extends State<AddCustoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  TipoCusto _tipo = TipoCusto.fixo;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.custo?.descricao ?? '');
    _valorController = TextEditingController(text: widget.custo?.valor.toString() ?? '');
    _tipo = widget.custo?.tipo ?? TipoCusto.fixo;
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
        empresaId: widget.custo?.empresaId ?? 'id_da_empresa_logada',
        descricao: _descricaoController.text,
        valor: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
        tipo: _tipo,
        criadoPor: widget.custo?.criadoPor ?? {'nome': 'Usuário Atual'},
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
            DropdownButtonFormField<TipoCusto>(
              value: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo de Custo'),
              items: TipoCusto.values.map((TipoCusto value) {
                return DropdownMenuItem<TipoCusto>(value: value, child: Text(value.label));
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
