class Venda {
  int? id;
  int? fkCliente;
  DateTime dataVenda;
  double? vlTotal;

  Venda({this.id, this.fkCliente, required this.dataVenda, this.vlTotal});

  factory Venda.fromMap(Map<String, dynamic> map) {
    return Venda(
      id: map['id'],
      fkCliente: map['fk_cliente'],
      dataVenda: DateTime.parse(map['data_venda']),
      vlTotal: map['vl_total'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fk_cliente': fkCliente,
      'data_venda': dataVenda.toIso8601String(),
      'vl_total': vlTotal,
    };
  }
}
