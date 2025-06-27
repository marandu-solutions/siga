import 'package:cloud_firestore/cloud_firestore.dart';

// Representa um componente do estoque usado em um item do catálogo.
class ComponenteEstoque {
  final String estoqueId;
  final String nome;
  final double quantidadeUsada;

  ComponenteEstoque({
    required this.estoqueId,
    required this.nome,
    required this.quantidadeUsada,
  });

  factory ComponenteEstoque.fromMap(Map<String, dynamic> map) {
    return ComponenteEstoque(
      estoqueId: map['estoqueId'] ?? '',
      nome: map['nome'] ?? '',
      quantidadeUsada: (map['quantidadeUsada'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estoqueId': estoqueId,
      'nome': nome,
      'quantidadeUsada': quantidadeUsada,
    };
  }
}

// Representa um item do catálogo que a empresa vende.
class CatalogoItem {
  final String id;
  final String empresaId;
  final String nome;
  final String descricao;
  final double preco;
  final String? fotoUrl;
  final bool disponivel;
  final List<ComponenteEstoque> componentesEstoque;

  // ✅ Adicionando campos de auditoria para consistência
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Map<String, dynamic> criadoPor;

  CatalogoItem({
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.fotoUrl,
    this.disponivel = true,
    required this.componentesEstoque,
    required this.createdAt,
    required this.updatedAt,
    required this.criadoPor,
  });

  factory CatalogoItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CatalogoItem(
      id: doc.id,
      empresaId: data['empresaId'] ?? '',
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      preco: (data['preco'] as num?)?.toDouble() ?? 0.0,
      fotoUrl: data['fotoUrl'],
      disponivel: data['disponivel'] ?? true,
      componentesEstoque: (data['componentesEstoque'] as List<dynamic>?)
          ?.map((e) => ComponenteEstoque.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      criadoPor: data['criadoPor'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'fotoUrl': fotoUrl,
      'disponivel': disponivel,
      'componentesEstoque': componentesEstoque.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'criadoPor': criadoPor,
    };
  }
}