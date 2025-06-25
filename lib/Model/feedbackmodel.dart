import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ RENOMEADO de 'Feedback' para 'FeedbackModel' para evitar conflito com a classe nativa do Flutter.
class FeedbackModel {
  final String id;
  final String pedidoId;
  final String empresaId;
  final String mensagem;
  final bool positivo;
  final Timestamp data;
  final String nomeCliente;

  FeedbackModel({
    required this.id,
    required this.pedidoId,
    required this.empresaId,
    required this.mensagem,
    required this.positivo,
    required this.data,
    required this.nomeCliente,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      pedidoId: data['pedidoId'] ?? '',
      empresaId: data['empresaId'] ?? '',
      mensagem: data['mensagem'] ?? '',
      positivo: data['positivo'] ?? true,
      data: data['data'] ?? Timestamp.now(),
      nomeCliente: data['nomeCliente'] ?? 'Cliente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pedidoId': pedidoId,
      'empresaId': empresaId,
      'mensagem': mensagem,
      'positivo': positivo,
      'data': data,
      'nomeCliente': nomeCliente,
    };
  }
}