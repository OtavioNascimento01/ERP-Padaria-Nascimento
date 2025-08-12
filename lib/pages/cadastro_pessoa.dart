import 'package:flutter/material.dart';
import '../models/pessoa.dart';
import '../controllers/pessoa_controller.dart';

class CadastroPessoaPage extends StatefulWidget {
  const CadastroPessoaPage({Key? key}) : super(key: key);

  @override
  State<CadastroPessoaPage> createState() => _CadastroPessoaPageState();
}

class _CadastroPessoaPageState extends State<CadastroPessoaPage> {
  // Cores e estilos do app (iguais ao padrão anterior)
  final Color backgroundColor = Color.fromARGB(255, 189, 235, 255);
  final Color cardColor = Colors.white;
  final Color primaryColor = Color.fromARGB(255, 4, 43, 74);
  final Color fontColor = Color.fromARGB(255, 4, 43, 74);
  final Color lightFontColor = Colors.white;

  final estabelecimentoController = TextEditingController();
  final nomeController = TextEditingController();
  final cpfCnpjController = TextEditingController();
  final enderecoController = TextEditingController();

  String tipoSelecionado = "Cliente"; // "Cliente" ou "Fornecedor"

  final PessoaController _pessoaController = PessoaController();
  List<Pessoa> pessoas = [];
  int? selectedRow;

  @override
  void initState() {
    super.initState();
    carregarPessoas();
  }

  Future<void> carregarPessoas() async {
    try {
      final lista = await _pessoaController.buscarPessoas();
      setState(() {
        pessoas = lista;
      });
    } catch (e, stack) {
      print('Erro ao carregar pessoas: $e');
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar pessoas')));
      }
    }
  }

  void limparCampos() {
    estabelecimentoController.clear();
    nomeController.clear();
    cpfCnpjController.clear();
    enderecoController.clear();
    setState(() {
      tipoSelecionado = "Cliente";
      selectedRow = null;
    });
  }

  void salvarPessoa() async {
    final estabelecimento = estabelecimentoController.text.trim();
    final nome = nomeController.text.trim();
    final cpfCnpj = cpfCnpjController.text.trim();
    final endereco = enderecoController.text.trim();
    final tipo = tipoSelecionado;

    if (estabelecimento.isEmpty || tipo.isEmpty) return;

    final novaPessoa = Pessoa(
      id: selectedRow == null ? null : pessoas[selectedRow!].id,
      fantasia: estabelecimento,
      nome: nome,
      documento: cpfCnpj,
      endereco: endereco,
      tipo: tipo,
    );

    try {
      await _pessoaController.salvarPessoa(novaPessoa);
      await carregarPessoas();
      limparCampos();
    } catch (e) {
      print('Erro ao salvar pessoa: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar pessoa')));
    }
  }

  void editarPessoa(int index) {
    final pessoa = pessoas[index];
    estabelecimentoController.text = pessoa.nome;
    nomeController.text = pessoa.fantasia ?? '';
    cpfCnpjController.text = pessoa.documento ?? '';
    enderecoController.text = pessoa.endereco ?? '';
    setState(() {
      tipoSelecionado = pessoa.tipo ?? 'Cliente';
      selectedRow = index;
    });
  }

  void excluirPessoa(int index) async {
    final id = pessoas[index].id;
    if (id != null) {
      await _pessoaController.excluirPessoa(id);
      await carregarPessoas();
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
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tipos (Cliente e/ou Fornecedor)
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(
                      'Cliente',
                      style: TextStyle(
                        color:
                            tipoSelecionado == "Cliente"
                                ? lightFontColor
                                : fontColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    selected: tipoSelecionado == "Cliente",
                    selectedColor: primaryColor,
                    backgroundColor: cardColor,
                    onSelected: (v) {
                      setState(() {
                        tipoSelecionado = "Cliente";
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ChoiceChip(
                    label: Text(
                      'Fornecedor',
                      style: TextStyle(
                        color:
                            tipoSelecionado == "Fornecedor"
                                ? lightFontColor
                                : fontColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    selected: tipoSelecionado == "Fornecedor",
                    selectedColor: primaryColor,
                    backgroundColor: cardColor,
                    onSelected: (v) {
                      setState(() {
                        tipoSelecionado = "Fornecedor";
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Campos de cadastro
            _inputCard(
              child: TextField(
                controller: estabelecimentoController,
                decoration: InputDecoration(
                  labelText: "Mercado/Estabelecimento",
                  labelStyle: TextStyle(color: fontColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                style: TextStyle(color: fontColor, fontSize: 17),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            SizedBox(height: 8),
            _inputCard(
              child: TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: "Nome (Opcional)",
                  labelStyle: TextStyle(color: fontColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                style: TextStyle(color: fontColor, fontSize: 17),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            SizedBox(height: 8),
            _inputCard(
              child: TextField(
                controller: cpfCnpjController,
                decoration: InputDecoration(
                  labelText: "CPF/CNPJ (Opcional)",
                  labelStyle: TextStyle(color: fontColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                style: TextStyle(color: fontColor, fontSize: 17),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 8),
            _inputCard(
              child: TextField(
                controller: enderecoController,
                decoration: InputDecoration(
                  labelText: "Endereço (Opcional)",
                  labelStyle: TextStyle(color: fontColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                style: TextStyle(color: fontColor, fontSize: 17),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            SizedBox(height: 10),
            // Botões Limpar e Salvar
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: limparCampos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: fontColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: primaryColor, width: 1),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Limpar',
                      style: TextStyle(
                        color: fontColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: salvarPessoa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: lightFontColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      selectedRow == null ? 'Salvar' : 'Salvar Edição',
                      style: TextStyle(
                        color: lightFontColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            // Tabela de pessoas cadastradas
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
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
                    // Cabeçalho da tabela
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _tableHeader('Nome'),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _tableHeader('Tipo'),
                            ),
                          ),
                          SizedBox(width: 36),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1),
                    Expanded(
                      child:
                          pessoas.isEmpty
                              ? Center(
                                child: Text(
                                  'Nenhuma pessoa cadastrada.',
                                  style: TextStyle(
                                    color: fontColor,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.separated(
                                itemCount: pessoas.length,
                                separatorBuilder:
                                    (context, index) => Divider(
                                      height: 1,
                                      color: Colors.black12,
                                      thickness: 0.6,
                                    ),
                                itemBuilder: (context, index) {
                                  final pessoa = pessoas[index];
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
                                            flex: 6,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                pessoa.fantasia ?? pessoa.nome,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: fontColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                pessoa.tipo ?? '',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: fontColor,
                                                ),
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
                                                      () => editarPessoa(index),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.red[400],
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          excluirPessoa(index),
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

  // Card igual dos campos das outras telas
  Widget _inputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: child,
    );
  }

  Widget _tableHeader(String label) => Text(
    label,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: fontColor,
      fontSize: 15,
    ),
    textAlign: TextAlign.left,
  );
}
