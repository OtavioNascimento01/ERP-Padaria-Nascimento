import '../models/item_venda.dart';
import '../repositories/item_venda_repository.dart';

class ItemVendaController {
  final ItemVendaRepository _repository = ItemVendaRepository();

  Future<void> salvarItem(ItemVenda item) async {
    if (item.quantidade <= 0) {
      throw Exception('Quantidade deve ser maior que zero');
    }

    if (item.id == null) {
      await _repository.inserirItem(item);
    } else {
      await _repository.atualizarItem(item);
    }
  }

  Future<List<ItemVenda>> buscarItensDaVenda(int vendaId) {
    return _repository.listarItensPorVenda(vendaId);
  }

  Future<void> excluirItem(int id) async {
    await _repository.excluirItem(id);
  }
}
