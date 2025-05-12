import 'dart:convert';
import 'package:flutter/foundation.dart';

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

class FeedbackEntry {
  final String id;
  final String mensagem;
  final bool positive;
  final DateTime data;

  FeedbackEntry({
    required this.id,
    required this.mensagem,
    required this.positive,
    required this.data,
  });

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) => FeedbackEntry(
    id: json['id'] as String,
    mensagem: json['mensagem'] as String,
    positive: json['positive'] as bool,
    data: DateTime.parse(json['data'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'mensagem': mensagem,
    'positive': positive,
    'data': data.toIso8601String(),
  };
}

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
    preco: (json['preco'] as num?)?.toDouble() ?? 0.0,
    quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'preco': preco,
    'quantidade': quantidade,
  };
}

class Pedido {
  final String id;
  final String numeroPedido;
  final String nomeCliente;
  final String telefoneCliente;
  final List<Item> itens;
  final String observacoes;
  final DateTime dataEntrega;
  final DateTime dataPedido;
  final EstadoPedido estado;
  final String? fotoUrl;
  final List<FeedbackEntry> feedbacks;

  Pedido({
    required this.id,
    required this.numeroPedido,
    required this.nomeCliente,
    required this.telefoneCliente,
    required this.itens,
    required this.observacoes,
    required this.dataEntrega,
    required this.dataPedido,
    required this.estado,
    this.fotoUrl,
    List<FeedbackEntry>? feedbacks,
  }) : feedbacks = feedbacks ?? [];

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final detalhesString = json['detalhes'] as String? ?? '{}';
    final Map<String, dynamic> detalhes = jsonDecode(detalhesString);
    final List<dynamic> itensJson = detalhes['itens'] as List<dynamic>? ?? [];

    // Verificação para dataEntrega e dataPedido
    final dataEntregaStr = json['data_entrega'] as String?;
    final dataPedidoStr = json['xata'] != null ? json['xata']['createdAt'] as String? : null;

    return Pedido(
      id: json['id'] as String? ?? '',
      numeroPedido: detalhes['numeroPedido']?.toString() ?? '',
      nomeCliente: json['cliente_nome'] as String? ?? '',
      telefoneCliente: json['ccliente_contato'] as String? ?? '',
      itens: itensJson.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList(),
      observacoes: detalhes['observacoes'] as String? ?? '',
      dataEntrega: dataEntregaStr != null ? DateTime.parse(dataEntregaStr) : DateTime.now(),
      dataPedido: dataPedidoStr != null ? DateTime.parse(dataPedidoStr) : DateTime.now(),
      estado: EstadoPedido.fromString(json['status'] as String? ?? 'Em aberto'),
      fotoUrl: json['foto_url'] as String?,
      feedbacks: (json['feedbacks'] as List<dynamic>?)
          ?.map((e) => FeedbackEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_nome': nomeCliente,
      'ccliente_contato': telefoneCliente,
      'status': estado.label,
      'detalhes': jsonEncode({
        'numeroPedido': numeroPedido,
        'itens': itens.map((item) => item.toJson()).toList(),
        'observacoes': observacoes,
      }),
      'data_entrega': "${dataEntrega.toIso8601String()}Z",
      'foto_url': fotoUrl,
      'feedbacks': feedbacks.map((f) => f.toJson()).toList(),
    };
  }

  Pedido copyWith({
    String? id,
    String? numeroPedido,
    String? nomeCliente,
    String? telefoneCliente,
    List<Item>? itens,
    String? observacoes,
    DateTime? dataEntrega,
    DateTime? dataPedido,
    EstadoPedido? estado,
    String? fotoUrl,
    List<FeedbackEntry>? feedbacks,
  }) {
    return Pedido(
      id: id ?? this.id,
      numeroPedido: numeroPedido ?? this.numeroPedido,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      telefoneCliente: telefoneCliente ?? this.telefoneCliente,
      itens: itens ?? this.itens,
      observacoes: observacoes ?? this.observacoes,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      dataPedido: dataPedido ?? this.dataPedido,
      estado: estado ?? this.estado,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      feedbacks: feedbacks ?? List.from(this.feedbacks),
    );
  }
}

class NotificationEntry {
  final String pedidoId;
  final String mensagem;
  final DateTime data;

  NotificationEntry({
    required this.pedidoId,
    required this.mensagem,
    required this.data,
  });
}

class PedidoModel extends ChangeNotifier {
  final List<Pedido> _pedidos = [];
  final List<NotificationEntry> _notificacoes = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);
  List<NotificationEntry> get notificacoes => List.unmodifiable(_notificacoes);

  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    notifyListeners();
  }

  void removerPedido(String id) {
    _pedidos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void atualizarPedido(String id, Pedido pedidoAtualizado) {
    final idx = _pedidos.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _pedidos[idx] = pedidoAtualizado;
      notifyListeners();
    }
  }

  Pedido buscarPedidoPorId(String id) {
    return _pedidos.firstWhere((p) => p.id == id);
  }

  void limparPedidos() {
    _pedidos.clear();
    notifyListeners();
  }

  void adicionarFeedback(String pedidoId, FeedbackEntry feedback) {
    final idx = _pedidos.indexWhere((p) => p.id == pedidoId);
    if (idx != -1) {
      final p = _pedidos[idx];
      final atualizado = p.copyWith(
        feedbacks: [...p.feedbacks, feedback],
      );
      _pedidos[idx] = atualizado;
      notifyListeners();
    }
  }

  List<FeedbackEntry> feedbacksDoPedido(String pedidoId) {
    return buscarPedidoPorId(pedidoId).feedbacks;
  }

  void adicionarNotificacao({
    required String pedidoId,
    required String mensagem,
  }) {
    _notificacoes.add(NotificationEntry(
      pedidoId: pedidoId,
      mensagem: mensagem,
      data: DateTime.now(),
    ));
    notifyListeners();
  }
}