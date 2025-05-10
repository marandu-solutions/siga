// lib/Model/atendimento.dart
import 'package:flutter/foundation.dart';

/// Define os estados de um atendimento
enum EstadoAtendimento {
  emAberto,
  emAndamento,
  finalizado,
}

extension EstadoAtendimentoExtension on EstadoAtendimento {
  String get label {
    switch (this) {
      case EstadoAtendimento.emAberto:
        return 'Em Aberto';
      case EstadoAtendimento.emAndamento:
        return 'Em Andamento';
      case EstadoAtendimento.finalizado:
        return 'Finalizado';
    }
  }
}

/// Modelo de dados de um atendimento
class Atendimento {
  final String id;
  final String nomeCliente;
  final String telefoneCliente;
  final String? fotoUrl;
  final EstadoAtendimento estado;

  Atendimento({
    required this.id,
    required this.nomeCliente,
    required this.telefoneCliente,
    this.fotoUrl,
    this.estado = EstadoAtendimento.emAberto,
  });

  Atendimento copyWith({
    String? id,
    String? nomeCliente,
    String? telefoneCliente,
    String? fotoUrl,
    EstadoAtendimento? estado,
  }) {
    return Atendimento(
      id: id ?? this.id,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      telefoneCliente: telefoneCliente ?? this.telefoneCliente,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      estado: estado ?? this.estado,
    );
  }
}

class AtendimentoModel extends ChangeNotifier {
  final List<Atendimento> _atendimentos = [];

  List<Atendimento> get atendimentos => List.unmodifiable(_atendimentos);

  void adicionar(Atendimento item) {
    _atendimentos.add(item);
    notifyListeners();
  }

  void atualizar(String id, Atendimento atualizado) {
    final idx = _atendimentos.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _atendimentos[idx] = atualizado;
      notifyListeners();
    }
  }

  void remover(String id) {
    _atendimentos.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
