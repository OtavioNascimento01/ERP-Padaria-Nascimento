class ItemVenda {
  int? id;
  int fkVenda;
  int fkProduto;
  int quantidade;
  double vlVendaUnitario;
  double? vlTotalItem;

  ItemVenda({
    this.id,
    required this.fkVenda,
    required this.fkProduto,
    required this.quantidade,
    required this.vlVendaUnitario,
    this.vlTotalItem,
  });

  factory ItemVenda.fromMap(Map<String, dynamic> map) {
    return ItemVenda(
      id: map['id'],
      fkVenda: map['fk_venda'],
      fkProduto: map['fk_produto'],
      quantidade: map['quantidade'],
      vlVendaUnitario: map['vl_venda_unitario'],
      vlTotalItem: map['vl_total_item'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fk_venda': fkVenda,
      'fk_produto': fkProduto,
      'quantidade': quantidade,
      'vl_venda_unitario': vlVendaUnitario,
      'vl_total_item': vlTotalItem,
    };
  }
}
