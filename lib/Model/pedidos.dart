// lib/models/pedido_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ 1º: O enum (opcional, mas bom manter junto)
enum EstadoPedido {
  emAberto,
  emAndamento,
  entregaRetirada,
  finalizado,
  cancelado;

  String get label {
    switch (this) {
      case EstadoPedido.emAberto:
        return "Em aberto";
      case EstadoPedido.emAndamento:
        return "Em andamento";
      case EstadoPedido.entregaRetirada:
        return "Entrega/Retirada";
      case EstadoPedido.finalizado:
        return "Finalizado";
      case EstadoPedido.cancelado:
        return "Cancelado";
    }
  }

  static EstadoPedido fromString(String value) {
    switch (value.toLowerCase()) {
      case "em aberto":
        return EstadoPedido.emAberto;
      case "em andamento":
        return EstadoPedido.emAndamento;
      case "entrega/retirada":
        return EstadoPedido.entregaRetirada;
      case "finalizado":
        return EstadoPedido.finalizado;
      case "cancelado":
        return EstadoPedido.cancelado;
      default:
        return EstadoPedido.emAberto;
    }
  }
}


// ✅ 2º: DEFINA A CLASSE 'ITEM' PRIMEIRO, POIS 'PEDIDO' DEPENDE DELA.
class Item {
  final String nome;
  final double preco;
  final int quantidade;

  Item({
    required this.nome,
    required this.preco,
    required this.quantidade,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    nome: json['nome'] as String? ?? '',
    preco: (json['preco'] as num? ?? json['precoUnitario'] as num?)?.toDouble() ?? 0.0,
    quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'preco': preco,
    'quantidade': quantidade,
  };
}


// ✅ 3º: AGORA, DEFINA A CLASSE 'PEDIDO'. ELA JÁ SABE O QUE É UM 'ITEM'.
class Pedido {
  // --- Identificação e Rastreamento ---
  final String id; // ID do documento no Firestore
  final String empresaId;
  final String numeroPedido;

  // --- Dados do Pedido ---
  final String modalidade; // "DELIVERY", "RETIRADA", "LOCAL"
  final dynamic destino; // Pode ser um Map de endereço ou uma String de mesa
  final String status; // Armazena o 'label' do enum EstadoPedido
  final List<Item> itens; // Sem erro aqui!
  final double total;
  final String observacoes;
  
  // --- Dados do Cliente ---
  final Map<String, dynamic> cliente; // Mapa para { 'nome': '...', 'telefone': '...' }

  // --- Datas ---
  final Timestamp dataPedido;
  final Timestamp dataEntregaPrevista;

  // --- Auditoria ---
  final Map<String, dynamic> criadoPor;
  final Map<String, dynamic> atualizadoPor;
  final Timestamp atualizadoEm;

  Pedido({
    required this.id,
    required this.empresaId,
    required this.numeroPedido,
    required this.modalidade,
    this.destino,
    required this.status,
    required this.itens,
    required this.total,
    required this.observacoes,
    required this.cliente,
    required this.dataPedido,
    required this.dataEntregaPrevista,
    required this.criadoPor,
    required this.atualizadoPor,
    required this.atualizadoEm,
  });

  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Pedido(
      id: doc.id,
      empresaId: data['empresaId'] ?? '',
      numeroPedido: data['numeroPedido'] ?? '',
      modalidade: data['modalidade'] ?? 'RETIRADA',
      destino: data['destino'], // Pode ser nulo
      status: data['status'] ?? 'Em aberto',
      itens: (data['itens'] as List<dynamic>?)
          ?.map((item) => Item.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      observacoes: data['observacoes'] ?? '',
      cliente: data['cliente'] as Map<String, dynamic>? ?? {},
      dataPedido: data['dataPedido'] ?? Timestamp.now(),
      dataEntregaPrevista: data['dataEntregaPrevista'] ?? Timestamp.now(),
      criadoPor: data['criadoPor'] as Map<String, dynamic>? ?? {},
      atualizadoPor: data['atualizadoPor'] as Map<String, dynamic>? ?? {},
      atualizadoEm: data['atualizadoEm'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'numeroPedido': numeroPedido,
      'modalidade': modalidade,
      'destino': destino,
      'status': status,
      'itens': itens.map((item) => item.toJson()).toList(),
      'total': total,
      'observacoes': observacoes,
      'cliente': cliente,
      'dataPedido': dataPedido,
      'dataEntregaPrevista': dataEntregaPrevista,
      'criadoPor': criadoPor,
      'atualizadoPor': atualizadoPor,
      'atualizadoEm': atualizadoEm,
    };
  }
}