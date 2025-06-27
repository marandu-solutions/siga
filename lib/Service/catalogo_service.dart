import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siga/Model/catalogo.dart';

/// CatalogoService
///
/// Gerencia todas as operações de CRUD para a coleção 'catalogo' no Firestore.
class CatalogoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Coleção de referência para o catálogo com conversor, para um código mais limpo.
  CollectionReference<CatalogoItem> _catalogoRef(String empresaId) => _db
      .collection('catalogo')
      .withConverter<CatalogoItem>(
        fromFirestore: (snapshots, _) => CatalogoItem.fromFirestore(snapshots),
        toFirestore: (item, _) => item.toMap(),
      );

  // --- READ (LEITURA) ---

  /// Busca os itens do catálogo de uma empresa em tempo real.
  Stream<List<CatalogoItem>> getCatalogoDaEmpresaStream(String empresaId) {
    return _catalogoRef(empresaId)
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('nome') // Ordena por nome por padrão
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- CREATE (CRIAÇÃO) ---

  /// Adiciona um novo item ao catálogo.
  Future<void> adicionarItem(CatalogoItem item) async {
    try {
      // O método .add() cria um novo documento com ID automático.
      await _db.collection('catalogo').add(item.toMap());
    } catch (e) {
      print("❌ Erro ao adicionar item ao catálogo: $e");
      rethrow;
    }
  }

  // --- UPDATE (ATUALIZAÇÃO) ---

  /// Edita um item existente no catálogo.
  Future<void> editarItem(CatalogoItem item) async {
    try {
      // Usamos .update() no documento com o ID específico.
      // O toMap() já contém todos os campos, que serão sobrescritos.
      await _db.collection('catalogo').doc(item.id).update(item.toMap());
    } catch (e) {
      print("❌ Erro ao editar item do catálogo: $e");
      rethrow;
    }
  }

  // --- DELETE (EXCLUSÃO) ---

  /// Deleta permanentemente um item do catálogo.
  Future<void> deletarItem(String itemId) async {
    try {
      await _db.collection('catalogo').doc(itemId).delete();
    } catch (e) {
      print("❌ Erro ao deletar item do catálogo: $e");
      rethrow;
    }
  }
}