import 'package:flutter/material.dart';

class AlertaPage extends StatefulWidget {
  const AlertaPage({super.key});

  @override
  State<AlertaPage> createState() => _AlertaPageState();
}

class _AlertaPageState extends State<AlertaPage> {
  String? pedidoSelecionado;
  final TextEditingController motivoController = TextEditingController();

  final List<Map<String, String>> pedidos = [
    {'id': '001', 'nome': 'João Silva', 'detalhe': '100 camisas algodão'},
    {'id': '002', 'nome': 'Maria Souza', 'detalhe': '50 camisetas dri-fit'},
    {'id': '003', 'nome': 'Carlos Lima', 'detalhe': '200 camisas promocionais'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alertas de Atraso",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Selecione os pedidos que sofreram atraso:",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...pedidos.map((pedido) => _buildPedidoTile(pedido)).toList(),
            const SizedBox(height: 32),
            Text(
              "Explique o motivo do atraso:",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivoController,
              maxLines: 4,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText:
                "Ex: Nossa máquina de estampar quebrou. Previsão de retorno: 3 dias úteis.",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // aqui vai o envio para IA
                },
                icon: Icon(Icons.send),
                label: Text("Enviar Alerta"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPedidoTile(Map<String, String> pedido) {
    return InkWell(
      onTap: () {
        setState(() {
          pedidoSelecionado = pedido['id'];
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: pedidoSelecionado == pedido['id']
              ? Colors.blue.shade50
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: pedidoSelecionado == pedido['id']
                ? Colors.blue
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Text(
                pedido['id']!,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pedido['nome']!,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pedido['detalhe']!,
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                ],
              ),
            ),
            Radio<String>(
              value: pedido['id']!,
              groupValue: pedidoSelecionado,
              onChanged: (value) {
                setState(() {
                  pedidoSelecionado = value;
                });
              },
              activeColor: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
