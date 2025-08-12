import '../database/app_database.dart';
import '../models/item_venda.dart';

class ItemVendaRepository {
  Future<int> inserirItem(ItemVenda item) async {
    final db = await AppDatabase().database;
    return await db.insert('itens_venda', item.toMap());
  }

  Future<List<ItemVenda>> listarItensPorVenda(int vendaId) async {
    final db = await AppDatabase().database;
    final result = await db.query(
      'itens_venda',
      where: 'fk_venda = ?',
      whereArgs: [vendaId],
    );
    return result.map((map) => ItemVenda.fromMap(map)).toList();
  }

  Future<int> atualizarItem(ItemVenda item) async {
    final db = await AppDatabase().database;
    return await db.update(
      'itens_venda',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> excluirItem(int id) async {
    final db = await AppDatabase().database;
    return await db.delete('itens_venda', where: 'id = ?', whereArgs: [id]);
  }
}
