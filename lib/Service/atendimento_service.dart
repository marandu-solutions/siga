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

  /// ATUALIZA O ESTADO DE UM ATENDIMENTO.
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
  
  // ✅ NOVO MÉTODO PARA CRIAR UM ATENDIMENTO
  /// Adiciona um novo documento de atendimento à coleção.
  Future<void> adicionarAtendimento(Atendimento atendimento) async {
    try {
      // O método .add() cria um novo documento com um ID gerado automaticamente.
      // Usamos o .toMap() do nosso modelo para converter o objeto em um mapa
      // que o Firestore entende.
      await _db.collection('atendimentos').add(atendimento.toMap());
    } catch (e) {
      print("❌ Erro ao adicionar atendimento: $e");
      rethrow; // Relança o erro para que a UI possa tratar.
    }
  }

  // Aqui você pode adicionar um método para deletar um atendimento no futuro.
  // Future<void> deletarAtendimento(String atendimentoId) async { ... }
}