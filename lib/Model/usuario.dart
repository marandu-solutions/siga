class Usuario {
  final String id;
  final String nomeEmpresa;
  final String proprietario;
  final String email;
  final String telefone;

  Usuario({
    required this.id,
    required this.nomeEmpresa,
    required this.proprietario,
    required this.email,
    required this.telefone,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nomeEmpresa: map['nomeEmpresa'] ?? '',
      proprietario: map['proprietario'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeEmpresa': nomeEmpresa,
      'proprietario': proprietario,
      'email': email,
      'telefone': telefone,
    };
  }
}
