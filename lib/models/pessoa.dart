class Pessoa {
  int? id;
  String nome;
  String? fantasia;
  String? documento;
  String? tipo;
  String? endereco;

  Pessoa({
    this.id,
    required this.nome,
    this.fantasia,
    this.documento,
    this.tipo,
    this.endereco,
  });

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    return Pessoa(
      id: map['id'],
      nome: map['nome'] ?? '', // <- evita crash se estiver null
      fantasia: map['fantasia'],
      documento: map['documento'],
      tipo: map['tipo'],
      endereco: map['endereco'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'fantasia': fantasia,
      'documento': documento,
      'tipo': tipo,
      'endereco': endereco,
    };
  }
}
