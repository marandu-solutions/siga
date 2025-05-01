import 'package:flutter/material.dart';
import '../../../Model/pedidos.dart';

class PedidoDetailsPage extends StatelessWidget {
  final Pedido pedido;

  const PedidoDetailsPage({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme; // Obtendo o ColorScheme do tema
    final tt = theme.textTheme; // Obtendo o TextTheme do tema

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Pedido #${pedido.numeroPedido}",
          style: tt.titleLarge?.copyWith(color: cs.onPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Center(
                    child: Text(
                      "Detalhes do Pedido",
                      style: tt.headlineSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informação do cliente
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline, color: cs.primary),
                    title: Text(
                      pedido.nomeCliente,
                      style: tt.bodyLarge,
                    ),
                    subtitle: Text(
                      "Cliente",
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  const Divider(),

                  // Telefone
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.phone, color: cs.primary),
                    title: Text(
                      pedido.telefoneCliente,
                      style: tt.bodyLarge,
                    ),
                    subtitle: Text(
                      "Telefone",
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  const Divider(),

                  // Serviço
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.work_outline, color: cs.primary),
                    title: Text(
                      pedido.servico,
                      style: tt.bodyLarge,
                    ),
                    subtitle: Text(
                      "Serviço",
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  const Divider(),

                  // Quantidade e Tamanho
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.format_list_numbered, color: cs.primary),
                          title: Text(
                            pedido.quantidade.toString(),
                            style: tt.bodyLarge,
                          ),
                          subtitle: Text(
                            "Quantidade",
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.straighten, color: cs.primary),
                          title: Text(
                            pedido.tamanho,
                            style: tt.bodyLarge,
                          ),
                          subtitle: Text(
                            "Tamanho",
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Malha e Cor
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.layers, color: cs.primary),
                          title: Text(
                            pedido.tipoMalha,
                            style: tt.bodyLarge,
                          ),
                          subtitle: Text(
                            "Malha",
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.palette, color: cs.primary),
                          title: Text(
                            pedido.cor,
                            style: tt.bodyLarge,
                          ),
                          subtitle: Text(
                            "Cor",
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Valor
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.attach_money, color: cs.primary),
                    title: Text(
                      "R\$ ${pedido.valorTotal.toStringAsFixed(2)}",
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Valor Total",
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),

                  // Observações (se houver)
                  if (pedido.observacoes.isNotEmpty) ...[
                    const Divider(),
                    ExpansionTile(
                      leading: Icon(Icons.note_alt, color: cs.primary),
                      title: Text(
                        "Observações",
                        style: tt.bodyLarge,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            pedido.observacoes,
                            style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),

      // Botão de ação flutuante
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: cs.primary,
        icon: const Icon(Icons.check),
        label: const Text("Concluir"),
        onPressed: () {
          // aqui você pode disparar a ação de conclusão ou edição
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}
