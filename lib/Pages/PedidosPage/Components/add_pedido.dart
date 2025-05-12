import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../Model/pedidos.dart';
import '../../../Service/pedidos_service.dart';

class AddPedidoDialog extends StatefulWidget {
  final Function(Pedido) onAdd;

  const AddPedidoDialog({super.key, required this.onAdd});

  @override
  State<AddPedidoDialog> createState() => _AddPedidoDialogState();
}

class _AddPedidoDialogState extends State<AddPedidoDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeClienteController = TextEditingController();
  final _telefoneClienteController = TextEditingController();
  final _observacoesController = TextEditingController();
  EstadoPedido _estado = EstadoPedido.emAberto;
  DateTime _dataPedido = DateTime.now();
  DateTime _dataEntrega = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  final PedidoService _pedidoService = PedidoService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Lista de itens do pedido
  final List<Map<String, TextEditingController>> _itens = [];
  final List<GlobalKey<FormState>> _itensFormKeys = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();

    // Adicionar um item inicial
    _addItem();
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

  Future<void> _selectDate(BuildContext context, bool isDataPedido) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDataPedido ? _dataPedido : _dataEntrega,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDataPedido) {
          _dataPedido = picked;
        } else {
          _dataEntrega = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    bool allValid = true;
    for (var formKey in _itensFormKeys) {
      if (!formKey.currentState!.validate()) {
        allValid = false;
      }
    }

    if (_formKey.currentState!.validate() && allValid) {
      setState(() {
        _isLoading = true;
      });

      // Criar a lista de itens a partir dos controladores
      final List<Item> itens = _itens.asMap().entries.map((entry) {
        final item = entry.value;
        return Item(
          nome: item['nome']!.text,
          preco: double.parse(item['preco']!.text),
          quantidade: int.parse(item['quantidade']!.text),
        );
      }).toList();

      final novoPedido = Pedido(
        id: '', // Será preenchido pelo Xata
        numeroPedido: DateTime.now().millisecondsSinceEpoch.toString(),
        nomeCliente: _nomeClienteController.text,
        telefoneCliente: _telefoneClienteController.text,
        itens: itens,
        observacoes: _observacoesController.text,
        dataEntrega: _dataEntrega,
        dataPedido: _dataPedido,
        estado: _estado,
      );

      try {
        final pedidoCriado = await _pedidoService.adicionarPedido(novoPedido);
        widget.onAdd(pedidoCriado);
        Navigator.of(context).pop();
      } catch (e) {
        print('Erro ao adicionar pedido: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _telefoneClienteController.dispose();
    _observacoesController.dispose();
    for (var item in _itens) {
      item['nome']!.dispose();
      item['preco']!.dispose();
      item['quantidade']!.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 8,
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children: [
              Icon(
                LucideIcons.plusCircle,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adicionar Novo Pedido',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Preencha os detalhes do pedido',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    controller: _nomeClienteController,
                    label: 'Nome do Cliente',
                    icon: LucideIcons.user,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _telefoneClienteController,
                    label: 'Telefone do Cliente',
                    icon: LucideIcons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Telefone é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  ..._buildItensFields(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _observacoesController,
                    label: 'Observações',
                    icon: LucideIcons.messageSquare,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(),
                  const SizedBox(height: 16),
                  _buildDateField(context, 'Data do Pedido', _dataPedido, true),
                  const SizedBox(height: 16),
                  _buildDateField(context, 'Data de Entrega', _dataEntrega, false),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                'Cancelar',
                style: theme.textTheme.labelLarge,
              ),
            ),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: theme.filledButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.disabled)) {
                    return theme.colorScheme.primary.withOpacity(0.5);
                  }
                  return theme.colorScheme.primary;
                }),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                'Adicionar',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
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
                      icon: const Icon(LucideIcons.trash2, color: Colors.red),
                      onPressed: () => _removeItem(i),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _itens[i]['nome']!,
                label: 'Nome do Item',
                icon: LucideIcons.briefcase,
                validator: (value) =>
                value == null || value.isEmpty ? 'Nome do item é obrigatório' : null,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _itens[i]['preco']!,
                label: 'Preço (R\$)',
                icon: LucideIcons.dollarSign,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 8),
              _buildTextField(
                controller: _itens[i]['quantidade']!,
                label: 'Quantidade',
                icon: LucideIcons.hash,
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
    widgets.add(
      ElevatedButton.icon(
        onPressed: _addItem,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Adicionar Item'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
    );
    return widgets;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: theme.inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: theme.inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: theme.inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding: theme.inputDecorationTheme.contentPadding,
      ),
      style: TextStyle(color: theme.colorScheme.onSurface),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownField() {
    final theme = Theme.of(context);
    return DropdownButtonFormField<EstadoPedido>(
      value: _estado,
      decoration: InputDecoration(
        labelText: 'Estado',
        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(LucideIcons.tag, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: theme.inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: theme.inputDecorationTheme.contentPadding,
      ),
      style: TextStyle(color: theme.colorScheme.onSurface),
      items: EstadoPedido.values
          .map((estado) => DropdownMenuItem(
        value: estado,
        child: Text(estado.label),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _estado = value!;
        });
      },
    );
  }

  Widget _buildDateField(BuildContext context, String label, DateTime date, bool isDataPedido) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        LucideIcons.calendar,
        color: theme.colorScheme.primary,
      ),
      title: Text(label, style: theme.textTheme.labelLarge),
      subtitle: Text(
        date.toString().split(' ')[0],
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () => _selectDate(context, isDataPedido),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}