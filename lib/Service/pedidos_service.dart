import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siga/Model/pedidos.dart';

/// PedidoService
/// 
/// Gerencia todas as operações de CRUD (Create, Read, Update, Delete)
/// para a coleção 'pedidos' no Firestore.
class PedidoService {
  // Instância privada do Firestore para uso interno na classe.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Coleção de referência para os pedidos, para evitar repetição de código.
  CollectionReference<Pedido> get _pedidosRef => _db.collection('pedidos').withConverter<Pedido>(
        fromFirestore: (snapshots, _) => Pedido.fromFirestore(snapshots),
        toFirestore: (pedido, _) => pedido.toMap(),
      );

  // --- READ (LEITURA) ---

  /// Retorna uma stream com a lista de pedidos de uma empresa em tempo real.
  /// A UI se atualizará automaticamente sempre que um pedido for adicionado,
  /// modificado ou removido no Firestore.
  Stream<List<Pedido>> getPedidosDaEmpresaStream(String empresaId) {
    return _pedidosRef
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('dataPedido', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- CREATE (CRIAÇÃO) ---

  /// Adiciona um novo documento de pedido ao Firestore.
  /// O objeto 'pedido' deve ser criado na UI e passado para este método.
  Future<void> adicionarPedido(Pedido pedido) async {
    try {
      await _pedidosRef.add(pedido);
    } catch (e) {
      print("❌ Erro ao adicionar pedido: $e");
      // Relança o erro para que a UI possa tratar (ex: mostrar um SnackBar)
      rethrow;
    }
  }

  // --- UPDATE (ATUALIZAÇÃO) ---

  /// Atualiza especificamente o status de um pedido existente.
  Future<void> atualizarStatusPedido({
    required String pedidoId,
    required String novoStatus,
    required Map<String, dynamic> funcionarioQueAtualizou, // Para auditoria
  }) async {
    try {
      await _db.collection('pedidos').doc(pedidoId).update({
        'status': novoStatus,
        'atualizadoPor': funcionarioQueAtualizou,
        'atualizadoEm': Timestamp.now(),
      });
    } catch (e) {
      print("❌ Erro ao atualizar status do pedido: $e");
      rethrow;
    }
  }
  
  /// Atualiza dados genéricos de um pedido.
  /// É flexível para editar qualquer parte do pedido.
  Future<void> editarPedido({
    required String pedidoId,
    required Map<String, dynamic> dadosParaAtualizar,
    required Map<String, dynamic> funcionarioQueAtualizou,
  }) async {
    try {
      // Usamos um mapa para combinar os novos dados com os dados de auditoria
      final dadosCompletos = {
        ...dadosParaAtualizar,
        'atualizadoPor': funcionarioQueAtualizou,
        'atualizadoEm': Timestamp.now(),
      };
      
      await _db.collection('pedidos').doc(pedidoId).update(dadosCompletos);
    } catch (e) {
      print("❌ Erro ao editar pedido: $e");
      rethrow;
    }
  }

  // --- DELETE (EXCLUSÃO) ---

  /// Deleta permanentemente um pedido do Firestore.
  Future<void> deletarPedido(String pedidoId) async {
    try {
      await _db.collection('pedidos').doc(pedidoId).delete();
    } catch (e) {
      print("❌ Erro ao deletar pedido: $e");
      rethrow;
    }
  }
}