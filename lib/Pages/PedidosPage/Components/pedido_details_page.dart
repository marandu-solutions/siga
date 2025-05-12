import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Model/pedidos.dart';

/// Formatter customizado para telefone no padrão (##) #####-####
class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    var index = 0;

    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Abre parênteses
    buffer.write('(');
    // DDD
    if (digits.length >= 2) {
      buffer.write(digits.substring(0, 2));
      index = 2;
    } else {
      buffer.write(digits);
      index = digits.length;
    }

    // Fecha parênteses e espaço
    if (digits.length > 2) {
      buffer.write(') ');
    }

    // Número principal e hífen
    if (digits.length >= 7) {
      buffer.write(digits.substring(2, 7));
      buffer.write('-');
      buffer.write(digits.substring(7, digits.length > 11 ? 11 : digits.length));
    } else if (digits.length > 2) {
      buffer.write(digits.substring(2));
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PedidoDetailsPage extends StatefulWidget {
  final Pedido pedido;

  const PedidoDetailsPage({super.key, required this.pedido});

  @override
  State<PedidoDetailsPage> createState() => _PedidoDetailsPageState();
}

class _PedidoDetailsPageState extends State<PedidoDetailsPage> {
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _observacoesController;
  late EstadoPedido _estado;
  late List<Map<String, TextEditingController>> _itens;
  late List<GlobalKey<FormState>> _itensFormKeys;

  @override
  void initState() {
    super.initState();
    final p = widget.pedido;
    _nomeController = TextEditingController(text: p.nomeCliente);
    // Formata número inicial
    var tel = p.telefoneCliente.replaceAll(RegExp(r'\D'), '');
    _telefoneController = TextEditingController(text: _formatInitial(tel));
    _observacoesController = TextEditingController(text: p.observacoes);
    _estado = p.estado;

    // Inicializar a lista de itens a partir do pedido
    _itens = p.itens.map((item) {
      return {
        'nome': TextEditingController(text: item.nome),
        'preco': TextEditingController(text: item.preco.toString()),
        'quantidade': TextEditingController(text: item.quantidade.toString()),
      };
    }).toList();
    _itensFormKeys = List.generate(_itens.length, (_) => GlobalKey<FormState>());
  }

  String _formatInitial(String digits) {
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    buffer.write('(');
    if (digits.length >= 2) {
      buffer.write(digits.substring(0, 2));
    } else {
      buffer.write(digits);
    }
    if (digits.length > 2) buffer.write(') ');
    if (digits.length >= 7) {
      buffer.write(digits.substring(2, 7));
      buffer.write('-');
      buffer.write(digits.substring(7, digits.length > 11 ? 11 : digits.length));
    } else if (digits.length > 2) {
      buffer.write(digits.substring(2));
    }
    return buffer.toString();
  }

  void _addItem() {
    setState(() {
      _itens.add({
        'nome': TextEditingController(),
        'preco': TextEditingController(),
        'quantidade': TextEditingController(text: '1'),
      });
      _itensFormKeys.add(GlobalKey<FormState>());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itens[index].forEach((key, controller) => controller.dispose());
      _itens.removeAt(index);
      _itensFormKeys.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    for (var item in _itens) {
      item['nome']!.dispose();
      item['preco']!.dispose();
      item['quantidade']!.dispose();
    }
    super.dispose();
  }

  void _save() {
    bool allValid = true;
    for (var formKey in _itensFormKeys) {
      if (!formKey.currentState!.validate()) {
        allValid = false;
      }
    }

    if (!allValid) return;

    // Remove máscara e salva apenas dígitos
    final digits = _telefoneController.text.replaceAll(RegExp(r'\D'), '');
    final List<Item> updatedItens = _itens.asMap().entries.map((entry) {
      final item = entry.value;
      return Item(
        nome: item['nome']!.text,
        preco: double.parse(item['preco']!.text),
        quantidade: int.parse(item['quantidade']!.text),
      );
    }).toList();

    final atualizado = widget.pedido.copyWith(
      nomeCliente: _nomeController.text,
      telefoneCliente: digits,
      itens: updatedItens,
      observacoes: _observacoesController.text,
      estado: _estado,
    );
    context.read<PedidoModel>().atualizarPedido(widget.pedido.id, atualizado);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Pedido #${widget.pedido.numeroPedido}'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome Cliente'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefoneController,
              decoration: InputDecoration(labelText: 'Telefone Cliente'),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TelefoneInputFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildItensFields(),
            const SizedBox(height: 12),
            TextField(
              controller: _observacoesController,
              decoration: InputDecoration(labelText: 'Observações'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EstadoPedido>(
              value: _estado,
              decoration: InputDecoration(labelText: 'Estado'),
              items: EstadoPedido.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _estado = v);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _save,
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItensFields() {
    List<Widget> widgets = [];
    for (int i = 0; i < _itens.length; i++) {
      widgets.add(
        Form(
          key: _itensFormKeys[i],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Item ${i + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_itens.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(i),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _itens[i]['nome'],
                decoration: InputDecoration(labelText: 'Nome do Item'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nome do item é obrigatório' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itens[i]['quantidade'],
                      decoration: InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Quantidade é obrigatória';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Quantidade deve ser um número positivo';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _itens[i]['preco'],
                      decoration: InputDecoration(labelText: 'Preço (R\$)'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preço é obrigatório';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Preço deve ser um número positivo';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
    widgets.add(
      ElevatedButton.icon(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Item'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
    );
    return widgets;
  }
}