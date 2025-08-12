class Produto {
  int? id;
  String nome;
  double? custoUnitario;
  double? vlVendaUnitario;
  int? fkFornecedor;

  Produto({
    this.id,
    required this.nome,
    this.custoUnitario,
    this.vlVendaUnitario,
    this.fkFornecedor,
  });

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      custoUnitario: map['custo_unitario'],
      vlVendaUnitario: map['vl_venda_unitario'],
      fkFornecedor: map['fk_fornecedor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'custo_unitario': custoUnitario,
      'vl_venda_unitario': vlVendaUnitario,
      'fk_fornecedor': fkFornecedor,
    };
  }
}
