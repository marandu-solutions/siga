import 'dart:convert';
import 'package:http/http.dart' as http;


class UsuarioService {
  final String webhookUrl = 'https://webhook.lila.n8n.h2solucoes.top/webhook/login_siga';

  Future<bool> cadastrarUsuario({
    required String email,
    required String senha,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'intent': 'cadastro',
          'email': email,
          'senha': senha,
          'username': username,
        }),
      );

      // Log para depuração
      print('🚀 Tentativa de Cadastro:');
      print('   Email: $email');
      print('   Username: $username');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erro no cadastro: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> loginUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'intent': 'login',
          'email': email,
          'senha': senha,
        }),
      );

      print('🔑 Tentativa de Login:');
      print('   Email: $email');
      print('   Status Code: ${response.statusCode}');
      // print('   Response Body: ${response.body}'); // Pode conter token, logar com cautela

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['token'] != null) {
          final token = data['token'];

          // Decodifica o payload do JWT
          final parts = token.split('.');
          if (parts.length != 3) {
            print('❌ Erro no login: Token JWT inválido (não tem 3 partes)');
            return {'sucesso': false, 'mensagem': 'Token inválido'};
          }

          final payloadString = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final payloadMap = jsonDecode(payloadString);

          final expiresIn = payloadMap['expiresIn']; // Ou a chave correta para expiração
          // final userId = payloadMap['user_id']; // Ou a chave correta para o ID do usuário
          // final userRole = payloadMap['role']; // Ou a chave correta para o papel/permissão

          // Você pode querer retornar mais dados do payload do token se forem úteis
          return {
            'sucesso': true,
            'token': token,
            'expiresIn': expiresIn, // Certifique-se que esta chave existe no seu JWT payload
            // 'userId': userId,
            // 'role': userRole,
          };
        } else {
          print('❌ Erro no login: Token não retornado na resposta. Body: ${response.body}');
          return {'sucesso': false, 'mensagem': 'Token não retornado'};
        }
      } else {
        print('❌ Erro no login: Status ${response.statusCode}. Body: ${response.body}');
        return {'sucesso': false, 'mensagem': 'Erro no login (${response.statusCode}): ${response.body}'};
      }
    } catch (e) {
      print('❌ Erro na conexão durante o login: $e');
      return {'sucesso': false, 'mensagem': 'Erro na conexão: $e'};
      }
    }
}