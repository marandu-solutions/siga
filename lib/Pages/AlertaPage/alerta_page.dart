import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Model/pedidos.dart';
import 'components/historico_page.dart';

class AlertaPage extends StatefulWidget {
  const AlertaPage({Key? key}) : super(key: key);

  @override
  State<AlertaPage> createState() => _AlertaPageState();
}

class _AlertaPageState extends State<AlertaPage> {
  final motivoController = TextEditingController();
  final List<String> pedidosSelecionados = [];
  DateTime? novaData;

  @override
  void initState() {
    super.initState();
    motivoController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: novaData ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) {
        final theme = Theme.of(ctx);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
            dialogBackgroundColor: theme.colorScheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != novaData) {
      setState(() => novaData = picked);
    }
  }

  void _limparSelecao() => setState(() => pedidosSelecionados.clear());

  bool get podeEnviar =>
      pedidosSelecionados.isNotEmpty &&
          motivoController.text.trim().isNotEmpty &&
          novaData != null;

  void _enviarNotificacoes() {
    final pedidosModel = context.read<PedidoModel>();
    final formatted = '${novaData!.day}/${novaData!.month}/${novaData!.year}';

    for (final id in pedidosSelecionados) {
      final p = pedidosModel.buscarPedidoPorId(id);
      final msg = motivoController.text
          .replaceAll('{{nome}}', p.nomeCliente)
          .replaceAll('{{data}}', formatted);

      pedidosModel.adicionarNotificacao(
        pedidoId: id,
        mensagem: 'Pedido #${p.id.substring(0, 8)}: $msg',
      );

      debugPrint('Enviar para ${p.telefoneCliente}: $msg');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificações enviadas com sucesso!')),
    );
    _limparSelecao();
  }

  void _onPedidoToggled(String pedidoId) {
    setState(() {
      if (pedidosSelecionados.contains(pedidoId)) {
        pedidosSelecionados.remove(pedidoId);
      } else {
        pedidosSelecionados.add(pedidoId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pedidos = context.watch<PedidoModel>().pedidos.where((p) {
      return p.estado == EstadoPedido.emAberto ||
          p.estado == EstadoPedido.emAndamento ||
          p.estado == EstadoPedido.entregaRetirada;
    }).toList();

    final pedidosPanel = _PedidosPanel(
      pedidos,
      pedidosSelecionados,
      _limparSelecao,
      _onPedidoToggled,
    );
    final notificarPanel = _NotificarPanel(
      motivoController,
      novaData,
      _selecionarData,
      podeEnviar,
      _enviarNotificacoes,
    );

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        title: const Text('Alerta de Pedidos'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoricoPage()),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: pedidosPanel),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: notificarPanel),
              ],
            )
                : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 400, child: pedidosPanel),
                  const SizedBox(height: 24),
                  notificarPanel,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PedidosPanel extends StatelessWidget {
  const _PedidosPanel(
      this.pedidos,
      this.selecionados,
      this.onLimpar,
      this.onPedidoToggled,
      );

  final List<Pedido> pedidos;
  final List<String> selecionados;
  final VoidCallback onLimpar;
  final Function(String) onPedidoToggled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: cs.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pedidos Pendentes',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: pedidos.length,
                itemBuilder: (ctx, i) {
                  final p = pedidos[i];
                  final isSel = selecionados.contains(p.id);

                  final quantidadeTotal = p.itens.fold<int>(0,(sum, item) => sum + item.quantidade);
                  final itensText = p.itens.isNotEmpty
                      ? p.itens.length == 1
                      ? p.itens[0].nome
                      : "${p.itens[0].nome} e mais ${p.itens.length - 1} item${p.itens.length > 2 ? 's' : ''}"
                      : "Nenhum item";

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? cs.primary.withOpacity(0.15) : cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? cs.primary : cs.outline),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSel ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSel ? cs.primary : cs.onSurfaceVariant,
                      ),
                      title: Text(p.nomeCliente),
                      subtitle: Text('$quantidadeTotal x $itensText'),
                      trailing: Text('#${p.id.substring(0, 8)}'),
                      onTap: () => onPedidoToggled(p.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selecionados.length} selecionado(s)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextButton.icon(
                  onPressed: selecionados.isNotEmpty ? onLimpar : null,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificarPanel extends StatelessWidget {
  const _NotificarPanel(
      this.controller,
      this.data,
      this.onSelectDate,
      this.canSend,
      this.onSend,
      );

  final TextEditingController controller;
  final DateTime? data;
  final void Function(BuildContext) onSelectDate;
  final bool canSend;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Estilo de input que funciona em ambos os temas
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: cs.surfaceVariant.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notificar Clientes', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(data == null
                  ? 'Escolher Data'
                  : 'Data: ${data!.day}/${data!.month}/${data!.year}'),
              onPressed: () => onSelectDate(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Mensagem Personalizada', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            // CORREÇÃO APLICADA AQUI
            TextField(
              controller: controller,
              style: TextStyle(color: cs.onSurface), // Cor do texto digitado
              maxLines: 6,
              onChanged: (_) {},
              decoration: inputDecoration.copyWith(
                  hintText: 'Olá {{nome}}, seu pedido foi reagendado para {{data}}',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant)
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Será enviado via WhatsApp',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Enviar'),
                  onPressed: canSend ? onSend : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
