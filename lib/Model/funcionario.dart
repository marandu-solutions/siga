// lib/models/funcionario_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Funcionario {
  final String uid; // ID do documento (será o UID de login do funcionário)
  final String empresaId;
  final String nome;
  final String email;
  final String cargo; // "admin", "gerente", "operador"
  final bool ativo;

  Funcionario({
    required this.uid,
    required this.empresaId,
    required this.nome,
    required this.email,
    required this.cargo,
    this.ativo = true,
  });

  /// Construtor para criar a partir de um mapa do Firestore.
  factory Funcionario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Funcionario(
      uid: doc.id,
      empresaId: data['empresaId'] ?? '',
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      cargo: data['cargo'] ?? 'operador',
      ativo: data['ativo'] ?? true,
    );
  }

  /// Método para converter em um mapa para salvar no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'nome': nome,
      'email': email,
      'cargo': cargo,
      'ativo': ativo,
    };
  }
}