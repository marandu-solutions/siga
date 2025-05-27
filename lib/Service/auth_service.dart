// auth_service.dart (Certifique-se que esta é a versão que você está usando)
import 'dart:convert';
import 'dart:html' as html; // Específico para web

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _expiryKey = 'jwt_expiry';

  static void saveToken(String token, int expiresInSeconds) {
    html.window.localStorage[_tokenKey] = token;
    final DateTime expiryDate = DateTime.now().add(Duration(seconds: expiresInSeconds));
    html.window.localStorage[_expiryKey] = expiryDate.toIso8601String();
  }

  static String? getToken() => html.window.localStorage[_tokenKey];

  static void logout() {
    html.window.localStorage.remove(_tokenKey);
    html.window.localStorage.remove(_expiryKey);
  }

  static bool isLoggedIn() {
    final String? token = getToken();
    final String? expiryString = html.window.localStorage[_expiryKey];
    if (token == null || expiryString == null) return false;
    final DateTime? expiryDate = DateTime.tryParse(expiryString);
    if (expiryDate == null) return false;
    final bool stillLoggedIn = DateTime.now().isBefore(expiryDate);
    if (!stillLoggedIn) logout();
    return stillLoggedIn;
  }

  static Map<String, dynamic>? _decodeTokenPayload() {
    final String? token = getToken();
    if (token == null) return null;
    try {
      final List<String> parts = token.split('.');
      if (parts.length != 3) return null;
      final String payloadBase64 = parts[1];
      final String normalized = base64Url.normalize(payloadBase64);
      final String payloadString = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(payloadString) as Map<String, dynamic>?;
    } catch (e) {
      print('Erro ao decodificar token JWT no AuthService: $e');
      return null;
    }
  }

  // Retorna o 'subject' do JWT (xata_id da tabela Users)
  static Future<String?> getUserId() async {
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    return payloadMap?['subject']?.toString() ?? payloadMap?['sub']?.toString();
  }

  // Retorna o 'issuer' do JWT (para 'admin' ou 'user')
  static Future<String?> getIssuer() async {
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    return payloadMap?['issuer']?.toString() ?? payloadMap?['iss']?.toString();
  }

  // NOVO E CRUCIAL: Retorna o 'membro_id' do JWT (ID da tabela Membros)
  static Future<String?> getMembroIdDoUsuarioLogado() async {
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    final String? membroId = payloadMap?['membro_id']?.toString();
    if (membroId != null) {
      print('AuthService: ID de Membro (membro_id) do JWT: $membroId');
    } else {
      print('AuthService: Campo "membro_id" NÃO encontrado no payload JWT.');
    }
    return membroId;
    }
}