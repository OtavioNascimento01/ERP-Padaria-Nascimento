import '../models/pessoa.dart';
import '../repositories/pessoa_repository.dart';

class PessoaController {
  final PessoaRepository _repository = PessoaRepository();

  Future<void> salvarPessoa(Pessoa pessoa) async {
    try {
      if (pessoa.nome.isEmpty) {
        throw Exception('Nome é obrigatório');
      }

      if (pessoa.id == null) {
        await _repository.inserirPessoa(pessoa);
      } else {
        await _repository.atualizarPessoa(pessoa);
      }
    } catch (e) {
      print('Erro ao salvar pessoa: $e');
      rethrow;
    }
  }

  Future<List<Pessoa>> buscarPessoas() {
    return _repository.listarPessoas();
  }

  Future<void> excluirPessoa(int id) async {
    await _repository.excluirPessoa(id);
  }
}
