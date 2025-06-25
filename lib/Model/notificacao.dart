// lib/models/notificacao_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Notificacao {
  final String id;
  final String empresaId;
  final String pedidoId;
  final String clienteTelefone;
  final String mensagem;
  final String status;
  final Timestamp createdAt;

  Notificacao({
    required this.id,
    required this.empresaId,
    required this.pedidoId,
    required this.clienteTelefone,
    required this.mensagem,
    required this.status,
    required this.createdAt,
  });

  factory Notificacao.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Notificacao(
      id: doc.id,
      empresaId: data['empresaId'] ?? '',
      pedidoId: data['pedidoId'] ?? '',
      clienteTelefone: data['clienteTelefone'] ?? '',
      mensagem: data['mensagem'] ?? '',
      status: data['status'] ?? 'desconhecido',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}