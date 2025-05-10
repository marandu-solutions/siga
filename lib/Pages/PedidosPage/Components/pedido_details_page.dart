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
  late TextEditingController _servicoController;
  late TextEditingController _quantidadeController;
  late TextEditingController _valorController;
  late EstadoPedido _estado;

  @override
  void initState() {
    super.initState();
    final p = widget.pedido;
    _nomeController = TextEditingController(text: p.nomeCliente);
    // Formata número inicial
    var tel = p.telefoneCliente.replaceAll(RegExp(r'\D'), '');
    _telefoneController = TextEditingController(text: _formatInitial(tel));
    _servicoController = TextEditingController(text: p.servico);
    _quantidadeController = TextEditingController(text: p.quantidade.toString());
    _valorController = TextEditingController(text: p.valorTotal.toString());
    _estado = p.estado;
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

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _servicoController.dispose();
    _quantidadeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _save() {
    // Remove máscara e salva apenas dígitos
    final digits = _telefoneController.text.replaceAll(RegExp(r'\D'), '');
    final atualizado = widget.pedido.copyWith(
      nomeCliente: _nomeController.text,
      telefoneCliente: digits,
      servico: _servicoController.text,
      quantidade: int.tryParse(_quantidadeController.text) ?? widget.pedido.quantidade,
      valorTotal: double.tryParse(_valorController.text) ?? widget.pedido.valorTotal,
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
            TextField(
              controller: _servicoController,
              decoration: InputDecoration(labelText: 'Serviço'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantidadeController,
                    decoration: InputDecoration(labelText: 'Quantidade'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _valorController,
                    decoration: InputDecoration(labelText: 'Valor Total'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
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
}