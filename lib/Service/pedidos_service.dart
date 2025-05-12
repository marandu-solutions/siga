import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/pedidos.dart';

class PedidoService {
  final String xataBaseUrl = 'https://marandu-solutions-s-workspace-vtf0o3.us-east-1.xata.sh/db/Siga:main';
  final String xataApiKey = 'xau_L5DDTgkhxp63XDxdFdyee7Rv6kiuvpmP0';

  Future<List<Pedido>> getPedidos() async {
    final Uri url = Uri.parse('$xataBaseUrl/tables/pedidos/query');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $xataApiKey',
        'Content-Type': 'application/json',
      },
      body: '{}',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> rows = data['records'] ?? [];
      return rows.map((e) => Pedido.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      throw Exception('Falha ao carregar pedidos: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> atualizarEstadoPedido(String pedidoId, EstadoPedido novoEstado) async {
    final Uri url = Uri.parse('$xataBaseUrl/tables/pedidos/data/$pedidoId');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $xataApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': novoEstado.label, // Usa a representação em string do estado (ex.: "Em aberto")
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar estado do pedido: ${response.statusCode} - ${response.body}');
    }
  }
}