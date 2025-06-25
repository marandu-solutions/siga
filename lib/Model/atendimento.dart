import 'package:cloud_firestore/cloud_firestore.dart';

class Atendimento {
  final String id;
  final String empresaId;
  final String nomeCliente;
  final String telefoneCliente;
  final String? fotoUrl;
  final String status; // Ex: "Em Aberto", "Em Andamento", "Finalizado"
  final Timestamp updatedAt;

  Atendimento({
    required this.id,
    required this.empresaId,
    required this.nomeCliente,
    required this.telefoneCliente,
    this.fotoUrl,
    required this.status,
    required this.updatedAt,
  });

  factory Atendimento.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Atendimento(
      id: doc.id,
      empresaId: data['empresaId'] ?? '',
      nomeCliente: data['nomeCliente'] ?? '',
      telefoneCliente: data['telefoneCliente'] ?? '',
      fotoUrl: data['fotoUrl'],
      status: data['status'] ?? 'Em Aberto',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'nomeCliente': nomeCliente,
      'telefoneCliente': telefoneCliente,
      'fotoUrl': fotoUrl,
      'status': status,
      'updatedAt': updatedAt,
    };
  }
}