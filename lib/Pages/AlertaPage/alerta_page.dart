import 'package:flutter/material.dart';

class AlertaPage extends StatefulWidget {
  const AlertaPage({Key? key}) : super(key: key);

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
      initialDate: novaData ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurpleAccent,
            onPrimary: Colors.white,
            surface: Color(0xFF1A1A2E),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xFF1A1A2E),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131225),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // Mobile: empilha painéis
          if (width < 600) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPedidosPanel(),
                  const SizedBox(height: 24),
                  _buildNotificarPanel(),
                ],
              ),
            );
          }

          // Tablet: lado a lado com scroll horizontal se necessário
          if (width < 900) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: _buildPedidosPanel()),
                  const SizedBox(width: 24),
                  SizedBox(width: width - 300 - 56, child: _buildNotificarPanel()),
                ],
              ),
            );
          }

          // Desktop: lado a lado fixo
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 300, child: _buildPedidosPanel()),
                const SizedBox(width: 30),
                Expanded(child: _buildNotificarPanel()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPedidosPanel() {
    return Card(
      color: const Color(0xFF1E1B2E),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pedidos com Atraso',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                final pedido = pedidos[i];
                final selecionado = pedidosSelecionados.contains(pedido['id']);
                return Card(
                  color: selecionado
                      ? Colors.deepPurple.withOpacity(0.3)
                      : const Color(0xFF2A273C),
                  elevation: selecionado ? 4 : 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: selecionado ? Colors.deepPurpleAccent : Colors.transparent,
                        border: Border.all(color: Colors.deepPurpleAccent),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(pedido['nome']!, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(pedido['detalhe']!, style: const TextStyle(color: Colors.grey)),
                    trailing: Text('#\${pedido[id]}', style: const TextStyle(color: Colors.white70)),
                    onTap: () => setState(() {
                      if (selecionado) {
                        pedidosSelecionados.remove(pedido['id']);
                      } else {
                        pedidosSelecionados.add(pedido['id']!);
                      }
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.clear_all, color: Colors.deepPurpleAccent),
              label: const Text('Limpar Seleção', style: TextStyle(color: Colors.deepPurpleAccent)),
              onPressed: pedidosSelecionados.isNotEmpty ? _limparSelecao : null,
            ),
            const SizedBox(height: 8),
            Text('${pedidosSelecionados.length} selecionados', style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificarPanel() {
    return Card(
      color: const Color(0xFF1E1B2E),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notificar Clientes', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    novaData == null
                        ? 'Escolher Data'
                        : 'Data: ${novaData!.day}/${novaData!.month}/${novaData!.year}',
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    elevation: 4,
                  ),
                  onPressed: () => _selecionarData(context),
                ),
                if (novaData != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
                    onPressed: () => _selecionarData(context),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Mensagem Personalizada', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: TextField(
                controller: motivoController,
                expands: true,
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF2A273C),
                  hintText: 'Olá [Nome], informamos que... (use {{data}} para inserir a nova data automaticamente)',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Será enviado via WhatsApp para todos selecionados',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: podeEnviar ? Colors.deepPurpleAccent : Colors.white12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: podeEnviar ? 6 : 0,
                          ),
                          onPressed: podeEnviar ? () {/* Implementar envio */} : null,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Será enviado via WhatsApp para todos selecionados',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: podeEnviar ? Colors.deepPurpleAccent : Colors.white12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          elevation: podeEnviar ? 6 : 0,
                        ),
                        onPressed: podeEnviar ? () {/* Implementar envio */} : null,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }
}
