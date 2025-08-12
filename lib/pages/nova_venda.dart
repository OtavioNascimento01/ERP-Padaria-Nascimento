import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class Item {
  final String name;
  final int quantity;
  final double unitPrice;
  const Item({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
  double get sum => quantity * unitPrice;
}

class NovaVendaPage extends StatefulWidget {
  const NovaVendaPage({Key? key}) : super(key: key);

  @override
  State<NovaVendaPage> createState() => _NovaVendaPageState();
}

class _NovaVendaPageState extends State<NovaVendaPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController clientController = TextEditingController();

  final List<Item> items = [];
  int? selectedRow;

  final Map<String, double> predefinedProducts = {
    'Sanduíche': 4.00,
    'Integral': 6.00,
    'Centeio': 6.00,
    'Baguete': 4.50,
    'Cachorro': 4.50,
    'Caseiro': 4.50,
    'Cuca de Chocolate': 8.80,
    'Bolo Cenoura': 8.80,
    'Nega Maluca': 10.00,
    'Merengue': 4.50,
    'Salgadinho Salmoria': 4.50,
    'Farinha de Rosca': 4.50,
    'Polvilho Giongo': 5.50,
    'Batatinha Zeca': 5.50,
    'Biscoito Ana Rech': 6.00,
    'Biscoito Zeca': 8.50,
    'Rapadura Zeca': 7.00,
    'Pct Gajeta': 40.00,
    'Pct Centeio': 40.00,
    'Pct Cacetinho': 40.00,
    'Grostoli': 8.50,
  };

  double get total => items.fold(0, (sum, item) => sum + item.sum);

  void addItem() {
    final name = nameController.text.trim();
    final q = int.tryParse(quantityController.text) ?? 0;
    final p = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0;
    if (name.isEmpty || q <= 0 || p <= 0) return;
    setState(() {
      items.add(Item(name: name, quantity: q, unitPrice: p));
      nameController.clear();
      quantityController.clear();
      priceController.clear();
    });
  }

  void removeItem(int index) {
    setState(() => items.removeAt(index));
  }

  void clearAll() {
    setState(() {
      items.clear();
      nameController.clear();
      quantityController.clear();
      priceController.clear();
      clientController.clear();
    });
  }

  Future<void> editItem(int index) async {
    final item = items[index];
    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl = TextEditingController(
      text: item.unitPrice.toStringAsFixed(2),
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Editar Produto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor Unitário',
                  ),
                ),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('OK'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    final newName = nameCtrl.text.trim();
    final newQty = int.tryParse(qtyCtrl.text) ?? item.quantity;
    final newPrice =
        double.tryParse(priceCtrl.text.replaceAll(',', '.')) ?? item.unitPrice;
    setState(() {
      items[index] = Item(name: newName, quantity: newQty, unitPrice: newPrice);
    });
  }

  Future<void> generatePdfAndShare() async {
    // Obtém o nome do cliente do campo, ou substitui por "Cliente não informado"
    final clientName =
        (clientController.text.trim().isEmpty)
            ? "Cliente não informado"
            : clientController.text.trim();

    // Data atual
    final now = DateTime.now();
    final dateFormatted = DateFormat('dd/MM/yyyy').format(now);
    final dateForFile = DateFormat('dd-MM-yyyy').format(now);

    // Nome de arquivo sugerido
    String defaultFileName = '$clientName $dateForFile.pdf';

    // Janela para usuário confirmar/alterar o nome do arquivo
    final fileName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: defaultFileName);
        return AlertDialog(
          title: const Text('Salvar como'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nome do arquivo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                var text = controller.text.trim();
                if (text.isEmpty) text = defaultFileName;
                Navigator.pop(ctx, text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (fileName == null || fileName.trim().isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        build:
            (pdfContext) => [
              // Cabeçalho: nome e data lado a lado, alinhados visualmente
              pw.Row(
                children: [
                  pw.Text(
                    clientName,
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(
                      top: 4,
                    ), // Ajusta o alinhamento da data
                    child: pw.Text(
                      dateFormatted,
                      style: pw.TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(1.6), // Quantidade (menor)
                  1: pw.FlexColumnWidth(4.5), // Nome (bem maior)
                  2: pw.FlexColumnWidth(1.4), // Valor Unitário (menor)
                  3: pw.FlexColumnWidth(1.5), // Soma (médio)
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Quantidade',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Nome',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Valor Unitário',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Soma',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...items.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '${item.quantity}',
                            style: pw.TextStyle(fontSize: 14),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            item.name,
                            style: pw.TextStyle(fontSize: 14),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            item.unitPrice.toStringAsFixed(2),
                            style: pw.TextStyle(fontSize: 14),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            item.sum.toStringAsFixed(2),
                            style: pw.TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total: ${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color.fromARGB(255, 189, 235, 255);
    final Color primaryColor = Color.fromARGB(255, 4, 43, 74);
    final Color cardColor = Color.fromARGB(255, 255, 255, 255);
    final Color fontColor = Color.fromARGB(255, 4, 43, 74);
    final Color lightFontColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Registre uma nova venda',
          style: TextStyle(
            color: lightFontColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
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
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return predefinedProducts.keys
                      .where(
                        (key) => key.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      )
                      .toList();
                },
                fieldViewBuilder: (
                  context,
                  controller,
                  focusNode,
                  onEditingComplete,
                ) {
                  controller.text = nameController.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      labelText: 'Produto',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(color: fontColor, fontSize: 16),
                    onChanged: (v) => nameController.text = v,
                  );
                },
                onSelected: (String selection) {
                  nameController.text = selection;
                  priceController.text =
                      predefinedProducts[selection]?.toStringAsFixed(2) ?? '';
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 6),
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
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantidade',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(color: fontColor, fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 6),
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
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Valor unitário',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(color: fontColor, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(bottom: 10, top: 4),
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
              child: TextField(
                controller: clientController,
                decoration: InputDecoration(
                  labelText: 'Cliente (opcional)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(color: fontColor, fontSize: 16),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                // Botão "Adicionar Trocas" ocupa menos espaço (flex: 4)
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: fontColor,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1,
                    ),
                    child: Text(
                      'Adicionar Trocas',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: fontColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14),
                // Botão "Salvar Produto" ocupa mais espaço (flex: 5)
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: lightFontColor,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Salvar Produto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: lightFontColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.09),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _tableHeader('Quantidade', fontColor),
                          ),
                          Expanded(
                            flex: 5,
                            child: _tableHeader('Produto', fontColor),
                          ),
                          Expanded(
                            flex: 4,
                            child: _tableHeader('Valor unitário', fontColor),
                          ),
                          Expanded(
                            flex: 3,
                            child: _tableHeader('Soma', fontColor),
                          ),
                          SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1),
                    Expanded(
                      child:
                          items.isEmpty
                              ? Center(
                                child: Text(
                                  'Nenhum produto adicionado.',
                                  style: TextStyle(color: fontColor),
                                ),
                              )
                              : ListView.separated(
                                itemCount: items.length,
                                separatorBuilder:
                                    (context, index) => Divider(
                                      height: 1,
                                      color: Colors.black12,
                                      thickness: 0.6,
                                      indent: 0,
                                      endIndent: 0,
                                    ),
                                itemBuilder: (context, index) {
                                  final item = items[index];
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
                                              ? primaryColor.withOpacity(0.12)
                                              : Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 0,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${item.quantity}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: fontColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              item.name,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: fontColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              'R\$${item.unitPrice.toStringAsFixed(2)}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: fontColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              'R\$${item.sum.toStringAsFixed(2)}',
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
                                                      () => editItem(index),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.red[400],
                                                  ),
                                                  onPressed:
                                                      () => removeItem(index),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: fontColor,
                    ),
                  ),
                  Text(
                    'R\$${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: fontColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: clearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: fontColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Limpar',
                      style: TextStyle(
                        color: fontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: generatePdfAndShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Finalizar Venda',
                      style: TextStyle(
                        color: lightFontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String label, Color color) => Expanded(
    child: Text(
      label,
      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
      textAlign: TextAlign.center,
    ),
  );
}
