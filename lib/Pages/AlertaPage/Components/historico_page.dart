// lib/Pages/AlertaPage/Components/historico_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:siga/Model/notificacao.dart';
import 'package:siga/Service/auth_service.dart';
import 'package:siga/Service/notificacao_service.dart';


class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessamos os serviços necessários via Provider
    final authService = context.watch<AuthService>();
    final notificacaoService = context.read<NotificacaoService>();
    final empresaId = authService.empresaAtual?.id;
    
    // Formatter para a data, para não recriá-lo a cada item da lista
    final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Notificações'),
      ),
      // Usamos o StreamBuilder para ouvir as mudanças no Firestore
      body: empresaId == null
          ? const Center(child: Text('Empresa não encontrada. Faça login novamente.'))
          : StreamBuilder<List<Notificacao>>(
              // O stream agora vem do nosso NotificacaoService
              stream: notificacaoService.getNotificacoesDaEmpresaStream(empresaId),
              builder: (context, snapshot) {
                // Enquanto os dados carregam
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Se deu erro
                if (snapshot.hasError) {
                  return Center(child: Text("Erro ao carregar histórico: ${snapshot.error}"));
                }
                // Se não tem dados ou a lista está vazia
                final notificacoes = snapshot.data ?? [];
                if (notificacoes.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma notificação enviada ainda.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Se temos dados, construímos a lista
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notificacoes.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final theme = Theme.of(context);
                    final colorScheme = theme.colorScheme;
                    final textTheme = theme.textTheme;

                    // ✅ Usando o novo modelo 'Notificacao'
                    final entry = notificacoes[i];
                    // ✅ Convertendo o Timestamp do Firestore para DateTime
                    final data = entry.createdAt.toDate();
                    final dataFormatada = formatter.format(data);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Icon(Icons.history_toggle_off, color: colorScheme.primary),
                      title: Text(
                        entry.mensagem,
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Pedido ID: ${entry.pedidoId}'),
                      trailing: Text(
                        dataFormatada,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}