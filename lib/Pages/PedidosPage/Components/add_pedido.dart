import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../Model/pedidos.dart';

class AddPedidoDialog extends StatefulWidget {
  final Function(Pedido) onAdd;

  const AddPedidoDialog({super.key, required this.onAdd});

  @override
  State<AddPedidoDialog> createState() => _AddPedidoDialogState();
}

class _AddPedidoDialogState extends State<AddPedidoDialog> {
  // Chaves de formulário para cada passo, garantindo validação segmentada.
  final _formKeyCliente = GlobalKey<FormState>();
  final List<GlobalKey<FormState>> _itemFormKeys = [];

  // Controladores para os dados principais do pedido.
  final _nomeClienteController = TextEditingController();
  final _telefoneClienteController = TextEditingController();
  final _observacoesController = TextEditingController();
  EstadoPedido _estado = EstadoPedido.emAberto;
  DateTime _dataEntrega = DateTime.now().add(const Duration(days: 1));

  // Lista de itens do pedido.
  final List<Map<String, TextEditingController>> _itens = [];

  // Controle do Stepper e estado de carregamento.
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Adiciona um item inicial para que o formulário não comece vazio.
    _addItem();
  }

  // --- LÓGICA DE MANIPULAÇÃO DOS ITENS ---

  void _addItem() {
    setState(() {
      _itemFormKeys.add(GlobalKey<FormState>());
      _itens.add({
        'nome': TextEditingController(),
        'preco': TextEditingController(),
        'quantidade': TextEditingController(text: '1'),
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      // Importante dar dispose nos controladores para liberar memória.
      _itens[index].forEach((key, controller) => controller.dispose());
      _itens.removeAt(index);
      _itemFormKeys.removeAt(index);
    });
  }

  // --- LÓGICA DO STEPPER ---

  // Valida e avança para o próximo passo.
  void _onStepContinue() {
    bool isStepValid = false;
    switch (_currentStep) {
      case 0: // Valida o formulário do cliente.
        isStepValid = _formKeyCliente.currentState!.validate();
        break;
      case 1: // Valida todos os formulários dos itens.
        isStepValid = true;
        for (var key in _itemFormKeys) {
          if (!key.currentState!.validate()) {
            isStepValid = false;
          }
        }
        break;
      case 2: // Último passo, dispara o envio.
        _submit();
        return;
    }

    if (isStepValid && _currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  // Volta para o passo anterior.
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  // --- LÓGICA DE ENVIO E HELPERS ---

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataEntrega,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dataEntrega) {
      setState(() => _dataEntrega = picked);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final List<Item> itensList = _itens.map((itemControllers) {
      return Item(
        nome: itemControllers['nome']!.text,
        preco: double.tryParse(itemControllers['preco']!.text.replaceAll(',', '.')) ?? 0.0,
        quantidade: int.tryParse(itemControllers['quantidade']!.text) ?? 1,
      );
    }).toList();

    final novoPedido = Pedido(
      id: '', // Backend preenche
      numeroPedido: (DateTime.now().millisecondsSinceEpoch % 100000).toString(),
      nomeCliente: _nomeClienteController.text,
      telefoneCliente: _telefoneClienteController.text,
      itens: itensList,
      observacoes: _observacoesController.text,
      dataEntrega: _dataEntrega,
      dataPedido: DateTime.now(),
      estado: _estado,
    );

    // Simula um pequeno delay de rede para o feedback visual.
    await Future.delayed(const Duration(seconds: 1));

    widget.onAdd(novoPedido);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _telefoneClienteController.dispose();
    _observacoesController.dispose();
    for (var item in _itens) {
      item.forEach((key, controller) => controller.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Novo Pedido'),
      contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  FilledButton(
                    onPressed: details.onStepContinue,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(details.currentStep == 2 ? 'Finalizar' : 'Continuar'),
                  ),
                  const SizedBox(width: 12),
                  if (details.currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Voltar'),
                    ),
                ],
              ),
            );
          },
          steps: [
            _buildStepCliente(),
            _buildStepItens(),
            _buildStepDetalhes(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DOS PASSOS DO STEPPER ---

  Step _buildStepCliente() {
    return Step(
      title: const Text('Dados do Cliente'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeyCliente,
        child: Column(
          children: [
            TextFormField(
              controller: _nomeClienteController,
              decoration: const InputDecoration(labelText: 'Nome do Cliente', prefixIcon: Icon(LucideIcons.user)),
              validator: (v) => v!.isEmpty ? 'Nome é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefoneClienteController,
              decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(LucideIcons.phone)),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.length < 10 ? 'Número inválido' : null,
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStepItens() {
    return Step(
      title: const Text('Itens do Pedido'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          for (int i = 0; i < _itens.length; i++)
            _buildItemCard(i),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Adicionar Outro Item'),
          ),
        ],
      ),
    );
  }

  Step _buildStepDetalhes() {
    return Step(
      title: const Text('Detalhes e Entrega'),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          TextFormField(
            controller: _observacoesController,
            decoration: const InputDecoration(labelText: 'Observações', prefixIcon: Icon(LucideIcons.messageSquare)),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<EstadoPedido>(
            value: _estado,
            decoration: const InputDecoration(labelText: 'Estado do Pedido', prefixIcon: Icon(LucideIcons.tag)),
            items: EstadoPedido.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
            onChanged: (v) => setState(() => _estado = v!),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(LucideIcons.calendar),
            title: const Text('Data de Entrega'),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataEntrega)),
            onTap: _selectDate,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR PARA O CARD DE ITEM ---

  Widget _buildItemCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _itemFormKeys[index],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Item ${index + 1}', style: Theme.of(context).textTheme.titleMedium),
                  if (_itens.length > 1)
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: Colors.redAccent),
                      onPressed: () => _removeItem(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _itens[index]['nome'],
                decoration: const InputDecoration(labelText: 'Nome do Item'),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itens[index]['preco'],
                      decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (double.tryParse(v!.replaceAll(',', '.')) ?? 0) <= 0 ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _itens[index]['quantidade'],
                      decoration: const InputDecoration(labelText: 'Qtd.'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (int.tryParse(v!) ?? 0) <= 0 ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
