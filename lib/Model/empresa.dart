// lib/models/empresa_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Empresa {
  final String id; // ID do documento (será o UID do dono)
  final String nomeEmpresa;
  final String proprietario;
  final String email;
  final String telefone;
  final String cpf;
  final Timestamp createdAt;

  Empresa({
    required this.id,
    required this.nomeEmpresa,
    required this.proprietario,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.createdAt,
  });

  /// Construtor para criar uma instância a partir de um mapa do Firestore.
  factory Empresa.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Empresa(
      id: doc.id,
      nomeEmpresa: data['nomeEmpresa'] ?? '',
      proprietario: data['proprietario'] ?? '',
      email: data['email'] ?? '',
      telefone: data['telefone'] ?? '',
      cpf: data['cpf'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// Método para converter a instância em um mapa para salvar no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'nomeEmpresa': nomeEmpresa,
      'proprietario': proprietario,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'createdAt': createdAt,
      // O 'id' não é salvo no mapa, pois ele é o nome do documento.
    };
  }
}