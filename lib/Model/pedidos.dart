class Pedido {
  final int id;
  final String numeroPedido;
  final String nomeCliente;
  final String telefoneCliente;
  final String servico;
  final int quantidade;
  final String tamanho;
  final String tipoMalha;
  final String cor;
  final String observacoes;
  final double valorTotal;
  final DateTime dataPedido;
  EstadoPedido estado;

  Pedido({
    required this.id,
    required this.numeroPedido,
    required this.nomeCliente,
    required this.telefoneCliente,
    required this.servico,
    required this.quantidade,
    required this.tamanho,
    required this.tipoMalha,
    required this.cor,
    required this.observacoes,
    required this.valorTotal,
    required this.dataPedido,
    required this.estado,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      numeroPedido: json['numero_pedido'] ?? '',
      nomeCliente: json['nome_cliente'] ?? '',
      telefoneCliente: json['telefone_cliente'] ?? '',
      servico: json['servico'] ?? '',
      quantidade: json['quantidade'] ?? 0,
      tamanho: json['tamanho'] ?? '',
      tipoMalha: json['tipo_malha'] ?? '',
      cor: json['cor'] ?? '',
      observacoes: json['observacoes'] ?? '',
      valorTotal: (json['valor_total'] as num).toDouble(),
      dataPedido: DateTime.parse(json['data_pedido']),
      estado: EstadoPedido.fromString(json['estado'] ?? 'Em aberto'),
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
      'tamanho': tamanho,
      'tipo_malha': tipoMalha,
      'cor': cor,
      'observacoes': observacoes,
      'valor_total': valorTotal,
      'data_pedido': dataPedido.toIso8601String(),
      'estado': estado.label,
    };
  }
}

enum EstadoPedido {
  emAberto,
  emAndamento,
  entregaRetirada,
  finalizado;

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
      default:
        return EstadoPedido.emAberto;
    }
  }
}

