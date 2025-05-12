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

class Pedido {
  final String id;
  final String numeroPedido;
  final String nomeCliente;
  final String telefoneCliente;
  final String servico;
  final int quantidade;
  final String observacoes;
  final double valorTotal;
  final DateTime dataEntrega;
  final DateTime dataPedido;
  final EstadoPedido estado;
  final bool atendimentoHumano;
  final String? fotoUrl;
  final List<FeedbackEntry> feedbacks;

  Pedido({
    required this.id,
    required this.numeroPedido,
    required this.nomeCliente,
    required this.telefoneCliente,
    required this.servico,
    required this.quantidade,
    required this.observacoes,
    required this.valorTotal,
    required this.dataEntrega,
    required this.dataPedido,
    required this.estado,
    required this.atendimentoHumano,
    this.fotoUrl,
    List<FeedbackEntry>? feedbacks,
  }) : feedbacks = feedbacks ?? [];

  factory Pedido.fromJson(Map<String, dynamic> json) {
    // Desserializa a string JSON do campo detalhes para um Map
    final detalhesString = json['detalhes'] as String? ?? '{}';
    final Map<String, dynamic> detalhes = jsonDecode(detalhesString);

    return Pedido(
      id: json['id'] as String,
      numeroPedido: detalhes['numeroPedido']?.toString() ?? '',
      nomeCliente: json['cliente_nome'] as String? ?? '',
      telefoneCliente: json['ccliente_contato'] as String? ?? '',
      servico: detalhes['servico'] as String? ?? '',
      quantidade: (detalhes['quantidade'] as num?)?.toInt() ?? 0,
      observacoes: detalhes['observacoes'] as String? ?? '',
      valorTotal: (detalhes['valor_total'] as num?)?.toDouble() ?? 0.0,
      dataEntrega: DateTime.parse(json['data_entrega'] as String),
      dataPedido: DateTime.parse(json['xata']['createdAt'] as String),
      estado: EstadoPedido.fromString(json['status'] as String? ?? 'Em aberto'),
      atendimentoHumano: json['atendimento_humano'] as bool? ?? false,
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
        'servico': servico,
        'quantidade': quantidade,
        'observacoes': observacoes,
        'valor_total': valorTotal,
        'dataPedido': dataPedido.toIso8601String(),
      }),
      'data_entrega': "${dataEntrega.toIso8601String()}Z",
      'atendimento_humano': atendimentoHumano,
      'foto_url': fotoUrl,
      'feedbacks': feedbacks.map((f) => f.toJson()).toList(),
    };
  }

  Pedido copyWith({
    String? id,
    String? numeroPedido,
    String? nomeCliente,
    String? telefoneCliente,
    String? servico,
    int? quantidade,
    String? observacoes,
    double? valorTotal,
    DateTime? dataEntrega,
    DateTime? dataPedido,
    EstadoPedido? estado,
    bool? atendimentoHumano,
    String? fotoUrl,
    List<FeedbackEntry>? feedbacks,
  }) {
    return Pedido(
      id: id ?? this.id,
      numeroPedido: numeroPedido ?? this.numeroPedido,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      telefoneCliente: telefoneCliente ?? this.telefoneCliente,
      servico: servico ?? this.servico,
      quantidade: quantidade ?? this.quantidade,
      observacoes: observacoes ?? this.observacoes,
      valorTotal: valorTotal ?? this.valorTotal,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      dataPedido: dataPedido ?? this.dataPedido,
      estado: estado ?? this.estado,
      atendimentoHumano: atendimentoHumano ?? this.atendimentoHumano,
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