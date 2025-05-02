import 'package:flutter/foundation.dart';
import 'pedidos.dart';

class PedidoModel extends ChangeNotifier {
  final List<Pedido> _pedidos = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

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
}
