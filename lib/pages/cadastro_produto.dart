import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../controllers/produto_controller.dart';

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({Key? key}) : super(key: key);

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  // Paleta
  final Color backgroundColor = Color.fromARGB(255, 189, 235, 255);
  final Color cardColor = Colors.white;
  final Color primaryColor = Color.fromARGB(255, 4, 43, 74);
  final Color fontColor = Color.fromARGB(255, 4, 43, 74);
  final Color lightFontColor = Colors.white;

  // Controllers
  final nomeController = TextEditingController();
  final custoController = TextEditingController();
  final vendaController = TextEditingController();
  final fornecedorController = TextEditingController();
  final ProdutoController _produtoController = ProdutoController();
  List<Produto> produtos = [];
  int? selectedRow;

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    try {
      final lista = await _produtoController.buscarProdutos();
      setState(() {
        produtos = lista;
      });
    } catch (e) {
      print('Erro ao carregar produtos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Erro ao carregar produtos')));
      }
    }
  }

  void limparCampos() {
    nomeController.clear();
    custoController.clear();
    vendaController.clear();
    fornecedorController.clear();
    setState(() {
      selectedRow = null;
    });
  }

  void salvarProduto() async {
    final nome = nomeController.text.trim();
    final custo = double.tryParse(custoController.text.replaceAll(',', '.'));
    final venda = double.tryParse(vendaController.text.replaceAll(',', '.'));
    final fkFornecedor = int.tryParse(fornecedorController.text.trim());

    if (nome.isEmpty || custo == null || venda == null) return;

    final produto = Produto(
      id: selectedRow == null ? null : produtos[selectedRow!].id,
      nome: nome,
      custoUnitario: custo,
      vlVendaUnitario: venda,
      fkFornecedor: fkFornecedor,
    );

    try {
      await _produtoController.salvarProduto(produto);
      await carregarProdutos();
      limparCampos();
    } catch (e) {
      print('Erro ao salvar produto: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao salvar produto')));
    }
  }

  void editarProduto(int index) {
    final produto = produtos[index];
    nomeController.text = produto.nome;
    custoController.text =
        (produto.custoUnitario ?? 0).toStringAsFixed(2);
    vendaController.text =
        (produto.vlVendaUnitario ?? 0).toStringAsFixed(2);
    fornecedorController.text =
        produto.fkFornecedor?.toString() ?? '';
    setState(() {
      selectedRow = index;
    });
  }

  void excluirProduto(int index) async {
    final id = produtos[index].id;
    if (id != null) {
      await _produtoController.excluirProduto(id);
      await carregarProdutos();
      limparCampos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Cadastros",
          style: TextStyle(color: lightFontColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título e formulário
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 6),
              child: Text(
                "Cadastre um produto:",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: fontColor,
                ),
              ),
            ),
            // Nome do Produto
            _inputCard(
              child: TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: "Nome do Produto",
                  labelStyle: TextStyle(color: fontColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                style: TextStyle(color: fontColor, fontSize: 17),
                keyboardType:
                    TextInputType
                        .text, // <-- Importante para aceitar caracteres especiais
                textCapitalization:
                    TextCapitalization.words, // Opcional, deixa mais bonito
              ),
            ),
            SizedBox(height: 8),
            // Custo e Valor Venda (lado a lado)
            Row(
              children: [
                Expanded(
                  child: _inputCard(
                    child: TextField(
                      controller: custoController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: "Custo Unitário",
                        labelStyle: TextStyle(color: fontColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      style: TextStyle(color: fontColor, fontSize: 17),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _inputCard(
                    child: TextField(
                      controller: vendaController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: "Valor de Venda Unitário",
                        labelStyle: TextStyle(color: fontColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      style: TextStyle(color: fontColor, fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            _inputCard(
              child: TextField(
                controller: fornecedorController,
                decoration: InputDecoration(
                  labelText: "Fornecedor (Opcional)",
                  labelStyle: TextStyle(color: fontColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                style: TextStyle(color: fontColor, fontSize: 17),
              ),
            ),
            SizedBox(height: 10),
            // Botões Limpar e Salvar (mais compacto)
            Row(
              children: [
                _smallButton(
                  label: 'Limpar',
                  background: cardColor,
                  textColor: fontColor,
                  border: BorderSide(color: primaryColor, width: 1),
                  onTap: limparCampos,
                ),
                SizedBox(width: 16),
                _smallButton(
                  label:
                      selectedRow == null ? 'Salvar Produto' : 'Salvar Edição',
                  background: primaryColor,
                  textColor: lightFontColor,
                  onTap: salvarProduto,
                ),
              ],
            ),
            SizedBox(height: 16),
            // Tabela de produtos cadastrados
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                child: Column(
                  children: [
                    // Cabeçalho
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 0,
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: _tableHeader('Produto')),
                          Expanded(
                            flex: 3,
                            child: _tableHeader(
                              'Valor Custo',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: _tableHeader(
                              'Valor Venda',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(width: 36),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1),
                    // Linhas
                    Expanded(
                      child:
                          produtos.isEmpty
                              ? Center(
                                child: Text(
                                  'Nenhum produto cadastrado.',
                                  style: TextStyle(
                                    color: fontColor,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.separated(
                                itemCount: produtos.length,
                                separatorBuilder:
                                    (context, index) => Divider(
                                      height: 1,
                                      color: Colors.black12,
                                      thickness: 0.6,
                                    ),
                                itemBuilder: (context, index) {
                                  final produto = produtos[index];
                                  final isSelected = selectedRow == index;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedRow =
                                            selectedRow == index ? null : index;
                                      });
                                    },
                                    child: Container(
                                      color:
                                          isSelected
                                              ? primaryColor.withOpacity(0.11)
                                              : Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 0,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              produto.nome,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: fontColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'R\$${(produto.custoUnitario ?? 0).toStringAsFixed(2)}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: fontColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'R\$${(produto.vlVendaUnitario ?? 0).toStringAsFixed(2)}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: fontColor,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                    color: Colors.black38,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          editarProduto(index),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.red[400],
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          excluirProduto(index),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input card padrão do app, igual tela Nova Venda
  Widget _inputCard({required Widget child}) {
    return Container(
      height: 58,
      margin: EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // Botão pequeno igual Nova Venda
  Widget _smallButton({
    required String label,
    required Color background,
    required Color textColor,
    BorderSide? border,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: border ?? BorderSide.none,
            ),
            shadowColor: Colors.black45,
            elevation: 4,
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 19,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String label, {TextAlign textAlign = TextAlign.center}) =>
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: fontColor,
          fontSize: 15,
        ),
        textAlign: textAlign,
      );
}
