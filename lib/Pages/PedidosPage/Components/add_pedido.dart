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
  final _servicoController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  final _observacoesController = TextEditingController();
  final _valorTotalController = TextEditingController();
  EstadoPedido _estado = EstadoPedido.emAberto;
  DateTime _dataPedido = DateTime.now();
  DateTime _dataEntrega = DateTime.now().add(const Duration(days: 1));
  bool _atendimentoHumano = false;
  bool _isLoading = false;
  final PedidoService _pedidoService = PedidoService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final novoPedido = Pedido(
        id: '', // Será preenchido pelo Xata
        numeroPedido: DateTime.now().millisecondsSinceEpoch.toString(),
        nomeCliente: _nomeClienteController.text,
        telefoneCliente: _telefoneClienteController.text,
        servico: _servicoController.text,
        quantidade: int.parse(_quantidadeController.text),
        observacoes: _observacoesController.text,
        valorTotal: double.parse(_valorTotalController.text),
        dataEntrega: _dataEntrega,
        dataPedido: _dataPedido,
        estado: _estado,
        atendimentoHumano: _atendimentoHumano,
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
    _servicoController.dispose();
    _quantidadeController.dispose();
    _observacoesController.dispose();
    _valorTotalController.dispose();
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
                  _buildTextField(
                    controller: _servicoController,
                    label: 'Serviço',
                    icon: LucideIcons.briefcase,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Serviço é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _quantidadeController,
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
                  _buildTextField(
                    controller: _observacoesController,
                    label: 'Observações',
                    icon: LucideIcons.messageSquare,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _valorTotalController,
                    label: 'Valor Total (R\$)',
                    icon: LucideIcons.dollarSign,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Valor total é obrigatório';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Valor total deve ser um número positivo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(),
                  const SizedBox(height: 16),
                  _buildDateField(context, 'Data do Pedido', _dataPedido, true),
                  const SizedBox(height: 16),
                  _buildDateField(context, 'Data de Entrega', _dataEntrega, false),
                  const SizedBox(height: 16),
                  _buildSwitchField(),
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

  Widget _buildSwitchField() {
    final theme = Theme.of(context);
    return SwitchListTile(
      title: Text('Atendimento Humano', style: theme.textTheme.labelLarge),
      value: _atendimentoHumano,
      onChanged: (value) {
        setState(() {
          _atendimentoHumano = value;
        });
      },
      activeColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
    );
  }
}