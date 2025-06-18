import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../Model/pedidos.dart';

// Seu TelefoneInputFormatter original, mantido pois é uma ótima implementação.
class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    if (digits.isEmpty) return newValue.copyWith(text: '');
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
    final formatted = buffer.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class PedidoDetailsPage extends StatefulWidget {
  final Pedido pedido;
  const PedidoDetailsPage({super.key, required this.pedido});

  @override
  State<PedidoDetailsPage> createState() => _PedidoDetailsPageState();
}

class _PedidoDetailsPageState extends State<PedidoDetailsPage> {
  // Chaves de formulário
  final _formKeyCliente = GlobalKey<FormState>();
  final List<GlobalKey<FormState>> _itemFormKeys = [];

  // Controladores
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _observacoesController;
  late EstadoPedido _estado;
  late List<Map<String, TextEditingController>> _itens;

  @override
  void initState() {
    super.initState();
    final p = widget.pedido;
    _nomeController = TextEditingController(text: p.nomeCliente);
    _telefoneController = TextEditingController(text: _formatInitial(p.telefoneCliente));
    _observacoesController = TextEditingController(text: p.observacoes);
    _estado = p.estado;
    _itens = p.itens.map((item) => {
      'nome': TextEditingController(text: item.nome),
      'preco': TextEditingController(text: item.preco.toStringAsFixed(2)),
      'quantidade': TextEditingController(text: item.quantidade.toString()),
    }).toList();
    _itemFormKeys.addAll(List.generate(_itens.length, (_) => GlobalKey<FormState>()));
  }

  // Sua lógica de formatação, adição/remoção de itens e dispose foi mantida.
  String _formatInitial(String digits) {
    if (digits.isEmpty) return '';
    final buffer = StringBuffer('(');
    if (digits.length >= 2) buffer.write(digits.substring(0, 2)); else buffer.write(digits);
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

  void _addItem() => setState(() {
    _itemFormKeys.add(GlobalKey<FormState>());
    _itens.add({'nome': TextEditingController(), 'preco': TextEditingController(), 'quantidade': TextEditingController(text: '1')});
  });

  void _removeItem(int index) => setState(() {
    _itens[index].forEach((_, controller) => controller.dispose());
    _itens.removeAt(index);
    _itemFormKeys.removeAt(index);
  });

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    for (var item in _itens) {
      item.forEach((_, controller) => controller.dispose());
    }
    super.dispose();
  }

  void _save() {
    bool isClienteValid = _formKeyCliente.currentState!.validate();
    bool allItensValid = true;
    for (var key in _itemFormKeys) {
      if (!key.currentState!.validate()) allItensValid = false;
    }

    if (!isClienteValid || !allItensValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, corrija os erros no formulário.'), backgroundColor: Colors.red));
      return;
    }

    final updatedItens = _itens.map((item) => Item(
      nome: item['nome']!.text,
      preco: double.tryParse(item['preco']!.text.replaceAll(',', '.')) ?? 0.0,
      quantidade: int.tryParse(item['quantidade']!.text) ?? 0,
    )).toList();

    final atualizado = widget.pedido.copyWith(
      nomeCliente: _nomeController.text,
      telefoneCliente: _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
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
          IconButton(icon: const Icon(Icons.save_outlined), onPressed: _save, tooltip: 'Salvar Alterações'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildClienteSection(),
            const SizedBox(height: 24),
            _buildItensSection(),
            const SizedBox(height: 24),
            _buildDetalhesSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _save,
                label: const Text('Salvar Alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEÇÕES DO FORMULÁRIO ---

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildClienteSection() {
    return _buildSectionCard(
      title: 'Dados do Cliente',
      child: Form(
        key: _formKeyCliente,
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(LucideIcons.user)),
              validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefoneController,
              decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(LucideIcons.phone)),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
              validator: (v) => v!.length < 14 ? 'Número inválido' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItensSection() {
    return _buildSectionCard(
      title: 'Itens do Pedido',
      child: Column(
        children: [
          for (int i = 0; i < _itens.length; i++)
            _buildItemCard(i),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Adicionar Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalhesSection() {
    return _buildSectionCard(
      title: 'Outros Detalhes',
      child: Column(
        children: [
          TextFormField(
            controller: _observacoesController,
            decoration: const InputDecoration(labelText: 'Observações', prefixIcon: Icon(LucideIcons.messageSquare)),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<EstadoPedido>(
            value: _estado,
            decoration: const InputDecoration(labelText: 'Status do Pedido', prefixIcon: Icon(LucideIcons.tag)),
            items: EstadoPedido.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
            onChanged: (v) => setState(() => _estado = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _itemFormKeys[index],
          child: Column(
            children: [
              Row(
                children: [
                  Text('Item ${index + 1}', style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  if (_itens.length > 1)
                    IconButton(icon: const Icon(LucideIcons.x, color: Colors.redAccent, size: 20), onPressed: () => _removeItem(index)),
                ],
              ),
              TextFormField(
                controller: _itens[index]['nome'],
                decoration: const InputDecoration(labelText: 'Nome do Item'),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _itens[index]['preco'], decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => (double.tryParse(v!.replaceAll(',', '.')) ?? 0) <= 0 ? 'Inválido' : null)),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _itens[index]['quantidade'], decoration: const InputDecoration(labelText: 'Qtd.'), keyboardType: TextInputType.number, validator: (v) => (int.tryParse(v!) ?? 0) <= 0 ? 'Inválido' : null)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
