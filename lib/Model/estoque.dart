class EstoqueItem {
  final String id;
  final String nome;
  double quantidade;
  final String unidade;
  final double nivelAlerta;

  EstoqueItem({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.nivelAlerta,
  });
}