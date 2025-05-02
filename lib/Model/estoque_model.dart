import 'package:flutter/foundation.dart';
import 'estoque.dart';

class EstoqueModel extends ChangeNotifier {
  final List<EstoqueItem> _itens = [];

  List<EstoqueItem> get itens => List.unmodifiable(_itens);

  void adicionar(EstoqueItem i) {
    _itens.add(i);
    notifyListeners();
  }

  void atualizar(int idx, EstoqueItem i) {
    _itens[idx] = i;
    notifyListeners();
  }

  void remover(int idx) {
    _itens.removeAt(idx);
    notifyListeners();
  }
}