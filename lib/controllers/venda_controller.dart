import '../models/venda.dart';
import '../repositories/venda_repository.dart';

class VendaController {
  final VendaRepository _repository = VendaRepository();

  Future<void> salvarVenda(Venda venda) async {
    if (venda.dataVenda == null) {
      throw Exception('Data da venda é obrigatória');
    }

    if (venda.id == null) {
      await _repository.inserirVenda(venda);
    } else {
      await _repository.atualizarVenda(venda);
    }
  }

  Future<List<Venda>> buscarVendas() {
    return _repository.listarVendas();
  }

  Future<void> excluirVenda(int id) async {
    await _repository.excluirVenda(id);
  }
}
