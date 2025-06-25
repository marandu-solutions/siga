import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:siga/Model/pedidos.dart';
import 'package:siga/Service/auth_service.dart';
import 'package:siga/Service/pedidos_service.dart';


class AddPedidoDialog extends StatefulWidget {
  // O callback agora é opcional e sinaliza o sucesso,
  // pois a UI principal se atualiza via StreamBuilder.
  final VoidCallback? onSuccess;

  const AddPedidoDialog({super.key, this.onSuccess});

  @override
  State<AddPedidoDialog> createState() => _AddPedidoDialogState();
}

class _AddPedidoDialogState extends State<AddPedidoDialog> {
  // Chaves de formulário para cada passo.
  final _formKeyCliente = GlobalKey<FormState>();
  final List<GlobalKey<FormState>> _itemFormKeys = [];

  // Controladores para os dados principais do pedido.
  final _nomeClienteController = TextEditingController();
  final _telefoneClienteController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  // Estado local para os detalhes do pedido.
  String _estado = EstadoPedido.emAberto.label;
  String _modalidade = 'RETIRADA'; // Valor padrão
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
    // 1. Acessamos os serviços e dados de autenticação
    final authService = context.read<AuthService>();
    final pedidoService = context.read<PedidoService>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final funcionario = authService.funcionarioLogado;
    final empresaId = authService.empresaAtual?.id;

    if (funcionario == null || empresaId == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Erro: Sessão inválida. Faça login novamente.')));
      return;
    }

    setState(() => _isLoading = true);

    // 2. Montamos a lista de Itens a partir dos controladores
    final List<Item> itensList = _itens.map((itemControllers) {
      return Item(
        nome: itemControllers['nome']!.text,
        preco: double.tryParse(itemControllers['preco']!.text.replaceAll(',', '.')) ?? 0.0,
        quantidade: int.tryParse(itemControllers['quantidade']!.text) ?? 1,
      );
    }).toList();
    
    // 3. Geramos um número de pedido legível
    final numeroPedido = 'P-${DateFormat('yyMMdd-HHmmss').format(DateTime.now())}';

    // 4. Criamos o objeto Pedido usando o NOVO MODELO
    final novoPedido = Pedido(
      id: '', // Firestore irá gerar
      empresaId: empresaId,
      numeroPedido: numeroPedido,
      modalidade: _modalidade,
      destino: null, // Pode ser preenchido com endereço ou número da mesa futuramente
      status: _estado,
      itens: itensList,
      total: itensList.fold(0.0, (sum, item) => sum + (item.preco * item.quantidade)),
      observacoes: _observacoesController.text.trim(),
      cliente: {
        'nome': _nomeClienteController.text.trim(),
        'telefone': _telefoneClienteController.text.trim(),
      },
      dataPedido: Timestamp.now(),
      dataEntregaPrevista: Timestamp.fromDate(_dataEntrega),
      criadoPor: {'uid': funcionario.uid, 'nome': funcionario.nome},
      atualizadoPor: {'uid': funcionario.uid, 'nome': funcionario.nome},
      atualizadoEm: Timestamp.now(),
    );

    // 5. Chamamos o serviço para adicionar o pedido
    try {
      await pedidoService.adicionarPedido(novoPedido);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Pedido #$numeroPedido adicionado com sucesso!')),
      );
      widget.onSuccess?.call(); // Chama o callback de sucesso, se houver
      navigator.pop(); // Fecha o diálogo
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erro ao adicionar pedido: $e')),
      );
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
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
        width: 500,
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
                    onPressed: _isLoading ? null : details.onStepContinue,
                    child: _isLoading && _currentStep == 2
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(details.currentStep == 2 ? 'Finalizar' : 'Avançar'),
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ).applyDefaults(theme.inputDecorationTheme);
  }

  Step _buildStepCliente() {
    final theme = Theme.of(context);
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
              decoration: _inputDecoration('Nome do Cliente', LucideIcons.user),
              validator: (v) => v!.isEmpty ? 'Nome é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefoneClienteController,
              decoration: _inputDecoration('Telefone', LucideIcons.phone),
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
    final theme = Theme.of(context);
    return Step(
      title: const Text('Detalhes e Entrega'),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          TextFormField(
            controller: _observacoesController,
            decoration: _inputDecoration('Observações', LucideIcons.messageSquare),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _estado,
            decoration: _inputDecoration('Estado do Pedido', LucideIcons.tag),
            items: EstadoPedido.values.map((e) => DropdownMenuItem(value: e.label, child: Text(e.label))).toList(),
            onChanged: (v) => setState(() => _estado = v!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _modalidade,
            decoration: _inputDecoration('Modalidade', LucideIcons.truck),
            items: ['RETIRADA', 'DELIVERY', 'LOCAL'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _modalidade = v!),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(LucideIcons.calendar, color: theme.colorScheme.primary),
            title: const Text('Data de Entrega'),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataEntrega)),
            onTap: _selectDate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
            ),
            tileColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final theme = Theme.of(context);
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
                  Text('Item ${index + 1}', style: theme.textTheme.titleMedium),
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
                decoration: _inputDecoration('Nome do Item', LucideIcons.package),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itens[index]['preco'],
                      decoration: _inputDecoration('Preço', LucideIcons.dollarSign).copyWith(prefixText: 'R\$ '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (double.tryParse(v!.replaceAll(',', '.')) ?? 0) <= 0 ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _itens[index]['quantidade'],
                      decoration: _inputDecoration('Qtd.', LucideIcons.hash),
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