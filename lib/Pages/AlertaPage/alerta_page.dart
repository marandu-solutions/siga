import 'package:flutter/material.dart';

class AlertaPage extends StatefulWidget {
  const AlertaPage({super.key});

  @override
  State<AlertaPage> createState() => _AlertaPageState();
}

class _AlertaPageState extends State<AlertaPage> {
  final TextEditingController motivoController = TextEditingController();
  final List<String> pedidosSelecionados = [];
  DateTime? novaData;
  final List<Map<String, String>> pedidos = [
    {'id': '001', 'nome': 'João Silva', 'detalhe': '100 camisas algodão'},
    {'id': '002', 'nome': 'Maria Souza', 'detalhe': '50 camisetas dri-fit'},
    {'id': '003', 'nome': 'Carlos Lima', 'detalhe': '200 camisas promocionais'},
  ];

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.purpleAccent,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != novaData) {
      setState(() => novaData = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Painel lateral de pedidos
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colors.error),
                    const SizedBox(width: 12),
                    Text(
                      "Pedidos com Atraso",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Material(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    child: ListView.separated(
                      itemCount: pedidos.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final pedido = pedidos[index];
                        final isSelecionado =
                        pedidosSelecionados.contains(pedido['id']);

                        return ListTile(
                          onTap: () => setState(() {
                            if (isSelecionado) {
                              pedidosSelecionados.remove(pedido['id']);
                            } else {
                              pedidosSelecionados.add(pedido['id']!);
                            }
                          }),
                          leading: Checkbox(
                            value: isSelecionado,
                            onChanged: (_) => setState(() {
                              if (isSelecionado) {
                                pedidosSelecionados.remove(pedido['id']);
                              } else {
                                pedidosSelecionados.add(pedido['id']!);
                              }
                            }),
                          ),
                          title: Text(
                            pedido['nome']!,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            pedido['detalhe']!,
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                          trailing: Text(
                            "#${pedido['id']}",
                            style: TextStyle(color: colors.outline),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${pedidosSelecionados.length} pedidos selecionados",
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Painel de mensagem
          Expanded(
            child: Material(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notificar Clientes",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Seletor de data
                    Row(
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            novaData == null
                                ? "Definir Nova Data"
                                : "Data: ${novaData!.day}/${novaData!.month}/${novaData!.year}",
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primaryContainer,
                            foregroundColor: colors.onPrimaryContainer,
                          ),
                          onPressed: () => _selecionarData(context),
                        ),
                        if (novaData != null)
                          IconButton(
                            icon: Icon(Icons.edit, color: colors.primary),
                            onPressed: () => _selecionarData(context),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Campo de mensagem
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mensagem Personalizada",
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TextField(
                              controller: motivoController,
                              maxLines: null,
                              expands: true,
                              style: TextStyle(color: colors.onSurface),
                              decoration: InputDecoration(
                                hintText: "Exemplo:\nOlá [Nome], informamos que... (use {{data}} para inserir a nova data automaticamente)",
                                hintStyle: TextStyle(color: colors.onSurfaceVariant),
                                filled: true,
                                fillColor: colors.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "A mensagem será enviada via WhatsApp\npara todos os clientes selecionados",
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        FilledButton.icon(
                          icon: const Icon(Icons.send_rounded),
                          label: const Text("Enviar Notificações"),
                          onPressed: (pedidosSelecionados.isNotEmpty &&
                              motivoController.text.isNotEmpty &&
                              novaData != null)
                              ? () {
                            // Implementar envio
                          }
                              : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}