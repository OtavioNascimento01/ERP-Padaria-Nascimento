import '../database/app_database.dart';
import '../models/venda.dart';

class VendaRepository {
  Future<int> inserirVenda(Venda venda) async {
    final db = await AppDatabase().database;
    return await db.insert('vendas', venda.toMap());
  }

  Future<List<Venda>> listarVendas() async {
    final db = await AppDatabase().database;
    final result = await db.query('vendas');
    return result.map((map) => Venda.fromMap(map)).toList();
  }

  Future<int> atualizarVenda(Venda venda) async {
    final db = await AppDatabase().database;
    return await db.update(
      'vendas',
      venda.toMap(),
      where: 'id = ?',
      whereArgs: [venda.id],
    );
  }

  Future<int> excluirVenda(int id) async {
    final db = await AppDatabase().database;
    return await db.delete('vendas', where: 'id = ?', whereArgs: [id]);
  }
}
