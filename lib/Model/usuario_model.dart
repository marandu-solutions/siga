import 'package:flutter/material.dart';
import 'usuario.dart';

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