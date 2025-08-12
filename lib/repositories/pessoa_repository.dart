import '../database/app_database.dart';
import '../models/pessoa.dart';

class PessoaRepository {
  Future<int> inserirPessoa(Pessoa pessoa) async {
    final db = await AppDatabase().database;
    return await db.insert('pessoas', pessoa.toMap());
  }

  Future<List<Pessoa>> listarPessoas() async {
    final db = await AppDatabase().database;
    final result = await db.query('pessoas');
    return result.map((map) => Pessoa.fromMap(map)).toList();
  }

  Future<int> atualizarPessoa(Pessoa pessoa) async {
    final db = await AppDatabase().database;
    return await db.update(
      'pessoas',
      pessoa.toMap(),
      where: 'id = ?',
      whereArgs: [pessoa.id],
    );
  }

  Future<int> excluirPessoa(int id) async {
    final db = await AppDatabase().database;
    return await db.delete('pessoas', where: 'id = ?', whereArgs: [id]);
  }
}
