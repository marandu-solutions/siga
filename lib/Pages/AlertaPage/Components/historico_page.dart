import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Model/pedidos_model.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtém todas as notificações e faz uma cópia para não alterar o Provider
    final notificacoes = List<NotificationEntry>.from(
      context.watch<PedidoModel>().notificacoes,
    )
    // Ordena da mais recente para a mais antiga
      ..sort((a, b) => b.data.compareTo(a.data));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Notificações'),
      ),
      body: notificacoes.isEmpty
          ? const Center(
        child: Text(
          'Nenhuma notificação enviada ainda.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notificacoes.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final entry = notificacoes[i];
          final data = entry.data;
          final dataFormatada =
              '${data.day.toString().padLeft(2, '0')}/'
              '${data.month.toString().padLeft(2, '0')}/'
              '${data.year} '
              '${data.hour.toString().padLeft(2, '0')}:'
              '${data.minute.toString().padLeft(2, '0')}';

          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: const Icon(Icons.history),
            title: Text(
              entry.mensagem,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('Pedido ID: ${entry.pedidoId}'),
            trailing: Text(
              dataFormatada,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          );
        },
      ),
    );
  }
}
