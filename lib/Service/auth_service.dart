import 'dart:convert';
import 'dart:html' as html; // Específico para web

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _expiryKey = 'jwt_expiry';

  // ... (os métodos saveToken, getToken, logout, isLoggedIn continuam iguais) ...
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

  // ✅ FUNCIONANDO: Retorna o 'subject' do JWT (ID do usuário)
  static Future<String?> getUserId() async {
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    return payloadMap?['subject']?.toString() ?? payloadMap?['sub']?.toString();
  }

  // ✅ FUNCIONANDO: Retorna o 'issuer' do JWT ('admin' ou 'user')
  static Future<String?> getIssuer() async {
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    return payloadMap?['issuer']?.toString() ?? payloadMap?['iss']?.toString();
  }

  // ✅ NOVO E FUNCIONANDO: Retorna o 'empresa_id' do JWT
  static Future<String?> getEmpresaId() async {
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    return payloadMap?['empresa_id']?.toString();
  }

  // ❌ NÃO FUNCIONA (depende do backend): Retorna o 'membro_id' do JWT
  static Future<String?> getMembroIdDoUsuarioLogado() async {
    // Este método só funcionará quando o backend adicionar "membro_id" ao payload do token.
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    final String? membroId = payloadMap?['membro_id']?.toString();
    if (membroId == null) {
      print('AVISO: O campo "membro_id" não foi encontrado no token JWT. Verifique o middleware.');
    }
    return membroId;
  }

  // ❌ NÃO FUNCIONA (depende do backend): Retorna o nome do usuário do JWT
  static Future<String?> getUserName() async {
    // Este método só funcionará quando o backend adicionar "name" (ou similar) ao payload do token.
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    final String? name = payloadMap?['name']?.toString() ?? payloadMap?['given_name']?.toString();
    if (name == null) {
      print('AVISO: O campo "name" não foi encontrado no token JWT. Verifique o middleware.');
    }
    return name;
  }

  // ❌ NÃO FUNCIONA (depende do backend): Retorna o e-mail do usuário do JWT
  static Future<String?> getUserEmail() async {
    // Este método só funcionará quando o backend adicionar "email" ao payload do token.
    final Map<String, dynamic>? payloadMap = _decodeTokenPayload();
    final String? email = payloadMap?['email']?.toString();
    if (email == null) {
      print('AVISO: O campo "email" não foi encontrado no token JWT. Verifique o middleware.');
    }
    return email;
  }
}