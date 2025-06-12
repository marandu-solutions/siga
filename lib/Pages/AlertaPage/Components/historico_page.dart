import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Model/pedidos.dart';

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
            // Pegamos o tema uma vez para reutilizar
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final textTheme = theme.textTheme;

            final entry = notificacoes[i];
            final data = entry.data;
            final dataFormatada =
                '${data.day.toString().padLeft(2, '0')}/'
                '${data.month.toString().padLeft(2, '0')}/'
                '${data.year.toString().substring(2)} ' // Usando apenas 2 dígitos para o ano, mais compacto
                '${data.hour.toString().padLeft(2, '0')}:'
                '${data.minute.toString().padLeft(2, '0')}';

            return ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              // Usando um ícone mais específico do tema, se disponível
              leading: Icon(Icons.history, color: colorScheme.primary),
              title: Text(
                entry.mensagem,
                // 1. Usando um estilo de texto do tema
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Pedido ID: ${entry.pedidoId}'),
              trailing: Text(
                dataFormatada,
                // 2. Usando uma cor do tema que se adapta aos modos claro/escuro
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            );
          },
      ),
    );
  }
}
