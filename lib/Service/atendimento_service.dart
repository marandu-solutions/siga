import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siga/Model/atendimento.dart';


class AtendimentoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Busca a lista de atendimentos de uma empresa em tempo real.
  Stream<List<Atendimento>> getAtendimentosDaEmpresaStream(String empresaId) {
    return _db
        .collection('atendimentos')
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Atendimento.fromFirestore(doc))
            .toList());
  }

  /// ATUALIZA O ESTADO DE UM ATENDIMENTO - O MÉTODO QUE VAMOS USAR!
  Future<void> atualizarEstadoAtendimento({
    required String atendimentoId,
    required String novoEstado,
    required Map<String, dynamic> funcionarioQueAtualizou,
  }) async {
    try {
      await _db.collection('atendimentos').doc(atendimentoId).update({
        'status': novoEstado,
        'updatedAt': Timestamp.now(),
        // Você pode adicionar um campo de auditoria se quiser
        // 'atualizadoPor': funcionarioQueAtualizou,
      });
    } catch (e) {
      print("❌ Erro ao atualizar estado do atendimento: $e");
      rethrow;
    }
  }
  
  // Aqui você pode adicionar outros métodos no futuro, como adicionar ou deletar um atendimento.
}