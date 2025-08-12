import '../models/produto.dart';
import '../repositories/produto_repository.dart';

class ProdutoController {
  final ProdutoRepository _repository = ProdutoRepository();

  Future<void> salvarProduto(Produto produto) async {
    if (produto.nome.isEmpty) {
      throw Exception('O nome do produto é obrigatório');
    }

    if (produto.id == null) {
      await _repository.inserirProduto(produto);
    } else {
      await _repository.atualizarProduto(produto);
    }
  }

  Future<List<Produto>> buscarProdutos() {
    return _repository.listarProdutos();
  }

  Future<void> excluirProduto(int id) async {
    await _repository.excluirProduto(id);
  }
}
