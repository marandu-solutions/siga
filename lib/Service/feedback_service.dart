import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siga/Model/feedbackmodel.dart';

class FeedbackService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ O método agora retorna um Stream de 'FeedbackModel'.
  Stream<List<FeedbackModel>> getFeedbacksDaEmpresaStream(String empresaId) {
    return _db
        .collectionGroup('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('data', descending: true)
        .limit(200)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList());
  }

  // ✅ O método agora recebe um objeto 'FeedbackModel' como parâmetro.
  Future<void> adicionarFeedback(String pedidoId, FeedbackModel feedback) async {
    try {
      await _db
          .collection('pedidos')
          .doc(pedidoId)
          .collection('feedbacks')
          .add(feedback.toMap());
    } catch (e) {
      print("❌ Erro ao adicionar feedback: $e");
      rethrow;
    }
  }
}