import 'package:flutter/material.dart';

class Usuario {
  final String id;
  final String nomeEmpresa;
  final String proprietario;
  final String email;
  final String telefone;

  Usuario({
    required this.id,
    required this.nomeEmpresa,
    required this.proprietario,
    required this.email,
    required this.telefone,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nomeEmpresa: map['nomeEmpresa'] ?? '',
      proprietario: map['proprietario'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeEmpresa': nomeEmpresa,
      'proprietario': proprietario,
      'email': email,
      'telefone': telefone,
    };
  }
}

class UsuarioProvider with ChangeNotifier {
  final List<Usuario> _usuarios = [];

  List<Usuario> get usuarios => List.unmodifiable(_usuarios);

  /// Carrega usuários iniciais, se necessário.
  /// No momento, não há persistência; a lista é inicializada vazia.
  void loadUsuarios(List<Usuario>? initialData) {
    _usuarios.clear();
    if (initialData != null) {
      _usuarios.addAll(initialData);
    }
    notifyListeners();
  }

  /// Adiciona um usuário à lista em memória.
  void addUsuario(Usuario usuario) {
    _usuarios.add(usuario);
    notifyListeners();
  }

  /// Atualiza um usuário existente na lista.
  void updateUsuario(Usuario usuario) {
    final index = _usuarios.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      _usuarios[index] = usuario;
      notifyListeners();
    }
  }

  /// Remove um usuário da lista pelo ID.
  void deleteUsuario(String id) {
    _usuarios.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  /// Limpa todos os usuários da lista.
  void clearUsuarios() {
    _usuarios.clear();
    notifyListeners();
  }
}