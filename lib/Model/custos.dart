/// Enum para os tipos de custo, garantindo segurança e consistência.
enum TipoCusto {
  fixo,
  variavel;

  String get label {
    switch (this) {
      case TipoCusto.fixo:
        return 'Fixo';
      case TipoCusto.variavel:
        return 'Variável';
    }
  }

  static TipoCusto fromString(String? value) {
    return value?.toLowerCase() == 'fixo' ? TipoCusto.fixo : TipoCusto.variavel;
  }
}

/// Representa uma despesa (fixa ou variável) da empresa.
class Custo {
  final String id;
  final String empresaId;
  final String descricao;
  final double valor;
  final TipoCusto tipo;
  final Map<String, dynamic> criadoPor;

  Custo({
    required this.id,
    required this.empresaId,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.criadoPor,
  });
}