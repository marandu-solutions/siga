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
    switch (value) {
      case "Em aberto":
        return EstadoPedido.emAberto;
      case "Em andamento":
        return EstadoPedido.emAndamento;
      case "Entrega/Retirada":
        return EstadoPedido.entregaRetirada;
      case "Finalizado":
        return EstadoPedido.finalizado;
      case "Cancelado":
        return EstadoPedido.cancelado;
      default:
        return EstadoPedido.emAberto;
    }
  }
}

/// Representa um feedback dado por cliente sobre um pedido
class FeedbackEntry {
  final String id;          // identificador único de feedback
  final String mensagem;
  final bool positive;      // true = positivo, false = negativo
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
  final int id;
  final String numeroPedido;
  final String nomeCliente;
  final String telefoneCliente;
  final String servico;
  final int quantidade;
  final String observacoes;
  final double valorTotal;
  final DateTime dataPedido;
  final EstadoPedido estado;

  // Atributos opcionais
  final String? nomeFuncionario;
  final String? fotoUrl;

  /// Lista de feedbacks associados a este pedido
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
    required this.dataPedido,
    required this.estado,
    this.nomeFuncionario,
    this.fotoUrl,
    List<FeedbackEntry>? feedbacks,
  }) : feedbacks = feedbacks ?? [];

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      numeroPedido: json['numero_pedido'] ?? '',
      nomeCliente: json['nome_cliente'] ?? '',
      telefoneCliente: json['telefone_cliente'] ?? '',
      servico: json['servico'] ?? '',
      quantidade: json['quantidade'] ?? 0,
      observacoes: json['observacoes'] ?? '',
      valorTotal: (json['valor_total'] as num).toDouble(),
      dataPedido: DateTime.parse(json['data_pedido']),
      estado: EstadoPedido.fromString(json['estado'] ?? 'Em aberto'),
      nomeFuncionario: json['nome_funcionario'],
      fotoUrl: json['foto_url'],
      feedbacks: (json['feedbacks'] as List<dynamic>?)
          ?.map((e) => FeedbackEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_pedido': numeroPedido,
      'nome_cliente': nomeCliente,
      'telefone_cliente': telefoneCliente,
      'servico': servico,
      'quantidade': quantidade,
      'observacoes': observacoes,
      'valor_total': valorTotal,
      'data_pedido': dataPedido.toIso8601String(),
      'estado': estado.label,
      'nome_funcionario': nomeFuncionario,
      'foto_url': fotoUrl,
      'feedbacks': feedbacks.map((f) => f.toJson()).toList(),
    };
  }

  Pedido copyWith({
    int? id,
    String? numeroPedido,
    String? nomeCliente,
    String? telefoneCliente,
    String? servico,
    int? quantidade,
    String? tamanho,
    String? tipoMalha,
    String? cor,
    String? observacoes,
    double? valorTotal,
    DateTime? dataPedido,
    EstadoPedido? estado,
    String? nomeFuncionario,
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
      dataPedido: dataPedido ?? this.dataPedido,
      estado: estado ?? this.estado,
      nomeFuncionario: nomeFuncionario ?? this.nomeFuncionario,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      feedbacks: feedbacks ?? List.from(this.feedbacks),
    );
  }
}

class NotificationEntry {
  final int pedidoId;
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

  /// Histórico de notificações enviadas
  final List<NotificationEntry> _notificacoes = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);
  List<NotificationEntry> get notificacoes => List.unmodifiable(_notificacoes);

  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    notifyListeners();
  }

  void removerPedido(int id) {
    _pedidos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void atualizarPedido(int id, Pedido pedidoAtualizado) {
    final idx = _pedidos.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _pedidos[idx] = pedidoAtualizado;
      notifyListeners();
    }
  }

  Pedido buscarPedidoPorId(int id) {
    return _pedidos.firstWhere((p) => p.id == id);
  }

  void limparPedidos() {
    _pedidos.clear();
    notifyListeners();
  }

  /// Adiciona um feedback a um pedido existente
  void adicionarFeedback(int pedidoId, FeedbackEntry feedback) {
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

  /// Retorna lista de feedbacks para um pedido
  List<FeedbackEntry> feedbacksDoPedido(int pedidoId) {
    return buscarPedidoPorId(pedidoId).feedbacks;
  }

  /// Adiciona uma notificação ao histórico
  void adicionarNotificacao({
    required int pedidoId,
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