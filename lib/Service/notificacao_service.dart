import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siga/Model/notificacao.dart';
/// NotificacaoService
///
/// Gerencia todas as operações de banco de dados para a coleção 'notificacoes'.
/// É responsável por criar novas notificações (para uma fila de envio)
/// e por ler o histórico de notificações enviadas.
class NotificacaoService {
  // Instância privada do Firestore para uso interno na classe.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- READ (LEITURA) ---

  /// Retorna uma stream com a lista das 100 notificações mais recentes de uma empresa.
  /// A UI se atualizará automaticamente sempre que uma nova notificação for criada.
  Stream<List<Notificacao>> getNotificacoesDaEmpresaStream(String empresaId) {
    return _db
        .collection('notificacoes')
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('createdAt', descending: true) // Ordena pelas mais recentes primeiro
        .limit(100) // Boa prática para evitar carregar históricos muito longos
        .snapshots() // Retorna o Stream em tempo real
        .map((snapshot) => snapshot.docs
            .map((doc) => Notificacao.fromFirestore(doc))
            .toList());
  }

  // --- CREATE (CRIAÇÃO) ---

  /// Adiciona uma operação para criar uma nova notificação a um 'WriteBatch'.
  ///
  /// Usar um batch é ideal quando a criação da notificação precisa acontecer
  /// junto com outra operação (ex: atualizar um pedido), garantindo que
  /// ou ambas funcionam, ou nenhuma funciona (atomicidade).
  void adicionarNotificacaoAoBatch(WriteBatch batch, {
    required String empresaId,
    required String pedidoId,
    required String clienteTelefone,
    required String mensagem,
  }) {
    // Pega uma referência para um novo documento com ID gerado automaticamente.
    final notificacaoRef = _db.collection('notificacoes').doc();
    
    // Adiciona a operação de 'set' ao batch, mas não a executa ainda.
    // A execução será feita pelo chamador do método através de `batch.commit()`.
    batch.set(notificacaoRef, {
      'empresaId': empresaId,
      'pedidoId': pedidoId,
      'clienteTelefone': clienteTelefone,
      'mensagem': mensagem,
      'status': 'pendente', // Status inicial para uma fila de envio
      'createdAt': Timestamp.now(), // Data e hora da criação
    });
  }
}