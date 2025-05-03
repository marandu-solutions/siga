// lib/Pages/AtendimentoPage/Components/alerta_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Model/pedidos.dart';
import '../../../Model/pedidos_model.dart';

class AlertaPage extends StatefulWidget {
  const AlertaPage({Key? key}) : super(key: key);

  @override
  State<AlertaPage> createState() => _AlertaPageState();
}

class _AlertaPageState extends State<AlertaPage> {
  final TextEditingController motivoController = TextEditingController();
  final List<int> pedidosSelecionados = [];
  DateTime? novaData;

  Future<void> _selecionarData(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: novaData ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: cs.copyWith(
            primary: cs.primary,
            onPrimary: cs.onPrimary,
            surface: cs.surface,
            onSurface: cs.onSurface,
          ),
          dialogBackgroundColor: cs.surface,
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != novaData) {
      setState(() => novaData = picked);
    }
  }

  void _limparSelecao() => setState(pedidosSelecionados.clear);

  bool get podeEnviar {
    return pedidosSelecionados.isNotEmpty &&
        motivoController.text.isNotEmpty &&
        novaData != null;
  }

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Filtra agora os pedidos que estão emAberto, emAndamento ou entregaRetirada
    final pedidos = context.watch<PedidoModel>().pedidos
        .where((p) =>
    p.estado == EstadoPedido.emAberto ||
        p.estado == EstadoPedido.emAndamento ||
        p.estado == EstadoPedido.entregaRetirada)
        .toList();

    return Scaffold(
      backgroundColor: cs.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width < 600) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPedidosPanel(cs, pedidos),
                  const SizedBox(height: 24),
                  _buildNotificarPanel(cs),
                ],
              ),
            );
          } else if (width < 900) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(width: 300, child: _buildPedidosPanel(cs, pedidos)),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: width - 300 - 56,
                    child: _buildNotificarPanel(cs),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SizedBox(width: 300, child: _buildPedidosPanel(cs, pedidos)),
                  const SizedBox(width: 30),
                  Expanded(child: _buildNotificarPanel(cs)),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPedidosPanel(ColorScheme cs, List<Pedido> pedidos) {
    return Card(
      color: cs.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    'Pedidos em Aberto, Em Andamento ou Entrega/Retirada',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pedidos.length,
              itemBuilder: (context, i) {
                final p = pedidos[i];
                final selecionado = pedidosSelecionados.contains(p.id);
                return Card(
                  color: selecionado ? cs.primary.withOpacity(0.2) : cs.surfaceVariant,
                  elevation: selecionado ? 4 : 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: selecionado ? cs.primary : Colors.transparent,
                        border: Border.all(color: cs.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(p.nomeCliente, style: TextStyle(color: cs.onSurface)),
                    subtitle: Text(
                      '${p.quantidade} x ${p.servico}',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    trailing: Text('#${p.numeroPedido}', style: TextStyle(color: cs.onSurfaceVariant)),
                    onTap: () => setState(() {
                      if (selecionado) {
                        pedidosSelecionados.remove(p.id);
                      } else {
                        pedidosSelecionados.add(p.id);
                      }
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: Icon(Icons.clear_all, color: cs.primary),
              label: Text('Limpar Seleção', style: TextStyle(color: cs.primary)),
              onPressed: pedidosSelecionados.isNotEmpty ? _limparSelecao : null,
            ),
            const SizedBox(height: 8),
            Text('${pedidosSelecionados.length} selecionados',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificarPanel(ColorScheme cs) {
    return Card(
      color: cs.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notificar Clientes',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(novaData == null
                      ? 'Escolher Data'
                      : 'Data: ${novaData!.day}/${novaData!.month}/${novaData!.year}'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: cs.onPrimary,
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    elevation: 4,
                  ),
                  onPressed: () => _selecionarData(context),
                ),
                if (novaData != null)
                  IconButton(
                    icon: Icon(Icons.edit, color: cs.primary),
                    onPressed: () => _selecionarData(context),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Mensagem Personalizada',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: TextField(
                controller: motivoController,
                expands: true,
                maxLines: null,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cs.surfaceVariant,
                  hintText:
                  'Olá {{nome}}, informamos que seu pedido foi reagendado para {{data}}',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, cons) {
                if (cons.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Será enviado via WhatsApp para todos selecionados',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: cs.onPrimary,
                            backgroundColor:
                            podeEnviar ? cs.primary : cs.surfaceVariant,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: podeEnviar ? 6 : 0,
                          ),
                          onPressed: podeEnviar ? _enviarNotificacoes : null,
                        ),
                      )
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Será enviado via WhatsApp para todos selecionados',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: cs.onPrimary,
                          backgroundColor:
                          podeEnviar ? cs.primary : cs.surfaceVariant,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                          elevation: podeEnviar ? 6 : 0,
                        ),
                        onPressed: podeEnviar ? _enviarNotificacoes : null,
                      )
                    ],
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void _enviarNotificacoes() {
    final pedidosModel = context.read<PedidoModel>();
    for (var id in pedidosSelecionados) {
      final p = pedidosModel.buscarPedidoPorId(id);
      final msg = motivoController.text
          .replaceAll('{{nome}}', p.nomeCliente)
          .replaceAll('{{data}}',
          '${novaData!.day}/${novaData!.month}/${novaData!.year}');
      // aqui você pode chamar um serviço de WhatsApp, por enquanto só print:
      debugPrint('Enviar para ${p.telefoneCliente}: $msg');
    }
  }
}
