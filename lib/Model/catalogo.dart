import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Representa um item do catálogo, incluindo foto em Base64.
class CatalogoItem extends ChangeNotifier {
  /// Identificador interno da empresa (não exibido ao usuário).
  final String empresa;
  final String nome;
  int quantidade;
  double preco;
  String descricao;
  String? fotoBase64;

  CatalogoItem({
    required this.empresa,
    required this.nome,
    required this.quantidade,
    required this.preco,
    required this.descricao,
    this.fotoBase64,
  });

  /// Converte bytes da imagem em Base64 e notifica ouvintes.
  void setFotoFromBytes(List<int> imageBytes) {
    fotoBase64 = base64Encode(imageBytes);
    notifyListeners();
  }

  /// Decodifica a string Base64 de volta para bytes de imagem.
  List<int>? getFotoBytes() {
    if (fotoBase64 == null) return null;
    return base64Decode(fotoBase64!);
  }
}

/// Gerencia o CRUD de CatalogoItem com notificações.
class CatalogoModel extends ChangeNotifier {
  final List<CatalogoItem> _itens = [];

  List<CatalogoItem> get itens => List.unmodifiable(_itens);

  /// Adiciona um novo item ao catálogo.
  void adicionar(CatalogoItem item) {
    _itens.add(item);
    item.addListener(notifyListeners);
    notifyListeners();
  }

  /// Atualiza o item na posição [idx] com novos valores.
  void atualizar(int idx, CatalogoItem novoItem) {
    final antigo = _itens[idx];
    antigo.removeListener(notifyListeners);
    _itens[idx] = novoItem;
    novoItem.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove o item da posição [idx].
  void remover(int idx) {
    final item = _itens.removeAt(idx);
    item.removeListener(notifyListeners);
    notifyListeners();
  }

  /// Captura de imagem e adição de item com foto.
  Future<void> pickImageAndAddItem({
    required String empresa,
    required String nome,
    required int quantidade,
    required double preco,
    required String descricao,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final item = CatalogoItem(
        empresa: empresa,
        nome: nome,
        quantidade: quantidade,
        preco: preco,
        descricao: descricao,
      );
      item.setFotoFromBytes(bytes);
      adicionar(item);
    }
  }
}