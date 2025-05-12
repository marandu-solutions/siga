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
        'status': novoEstado.label,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar estado do pedido: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> editarPedido(Pedido pedido) async {
    final Uri url = Uri.parse('$xataBaseUrl/tables/pedidos/data/${pedido.id}');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $xataApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cliente_nome': pedido.nomeCliente,
        'cliente_contato': pedido.telefoneCliente,
        'status': pedido.estado.label,
        'detalhes': jsonEncode({
          'numeroPedido': pedido.numeroPedido,
          'itens': pedido.itens.map((item) => item.toJson()).toList(),
          'observacoes': pedido.observacoes,
        }),
        'data_entrega': "${pedido.dataEntrega.toIso8601String()}Z",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao editar pedido: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deletarPedido(String pedidoId) async {
    final Uri url = Uri.parse('$xataBaseUrl/tables/pedidos/data/$pedidoId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $xataApiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar pedido: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Pedido> adicionarPedido(Pedido pedido) async {
    final Uri url = Uri.parse('$xataBaseUrl/tables/pedidos/data');
    final body = jsonEncode({
      'cliente_nome': pedido.nomeCliente,
      'cliente_contato': pedido.telefoneCliente,
      'status': pedido.estado.label,
      'detalhes': jsonEncode({
        'numeroPedido': pedido.numeroPedido,
        'itens': pedido.itens.map((item) => item.toJson()).toList(),
        'observacoes': pedido.observacoes,
      }),
      'data_entrega': "${pedido.dataEntrega.toIso8601String()}Z",
    });

    print('JSON enviado para o Xata: $body'); // Log para depuração

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $xataApiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print('Resposta do Xata: ${response.body}'); // Log para depuração
      return Pedido.fromJson(data);
    } else {
      throw Exception('Falha ao adicionar pedido: ${response.statusCode} - ${response.body}');
    }
  }
}