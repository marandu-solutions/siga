import 'package:flutter/foundation.dart';
import 'pedidos.dart';

/// Representa uma notificação enviada ao cliente
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
