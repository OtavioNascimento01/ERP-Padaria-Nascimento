import '../database/app_database.dart';
import '../models/produto.dart';

class ProdutoRepository {
  Future<int> inserirProduto(Produto produto) async {
    final db = await AppDatabase().database;
    return await db.insert('produtos', produto.toMap());
  }

  Future<List<Produto>> listarProdutos() async {
    final db = await AppDatabase().database;
    final result = await db.query('produtos');
    return result.map((map) => Produto.fromMap(map)).toList();
  }

  Future<int> atualizarProduto(Produto produto) async {
    final db = await AppDatabase().database;
    return await db.update(
      'produtos',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<int> excluirProduto(int id) async {
    final db = await AppDatabase().database;
    return await db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }
}
