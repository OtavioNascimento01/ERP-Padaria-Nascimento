import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  @override
  const NovaVendaPage({Key? key}) : super(key: key);

  @override
  State<NovaVendaPage> createState() => _NotaPageState();
}

class _NotaPageState extends State<NovaVendaPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final List<Item> items = [];

  // 1) Definição de quantidades disponíveis e variável de seleção
  final List<int> quantities = List.generate(20, (i) => i + 1);
  int selectedQuantity = 1;

  // Produtos pré-definidos
  final Map<String, double> predefinedProducts = {
    'Sanduíche': 3.50,
    'Integral': 6.00,
    'Centeio': 6.00,
    'Baguete': 4.50,
    'Cachorro': 4.50,
    'Pct Gajeta': 40.00,
    'Pct Centeio': 40.00,
    'Pct Cacetinho': 40.00,
  };
  String? selectedProduct;

  @override
  void initState() {
    super.initState();
    selectedProduct = predefinedProducts.keys.first;
    selectedQuantity = quantities.first;
  }

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

  void addPredefinedItem() {
    if (selectedProduct == null) return;
    setState(() {
      items.add(
        Item(
          name: selectedProduct!,
          quantity: selectedQuantity,
          unitPrice: predefinedProducts[selectedProduct!]!,
        ),
      );
    });
  }

  void removeItem(int index) {
    setState(() => items.removeAt(index));
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
    final storeName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Nome da Loja'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Digite nome da loja'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (storeName == null || storeName.trim().isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build:
            (pdfContext) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  storeName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.TableHelper.fromTextArray(
                headers: ['Quantidade', 'Nome', 'Valor Unitário', 'Soma'],
                data:
                    items
                        .map(
                          (item) => [
                            item.quantity,
                            item.name,
                            item.unitPrice.toStringAsFixed(2),
                            item.sum.toStringAsFixed(2),
                          ],
                        )
                        .toList(),
              ),
              pw.Paragraph(text: 'Total: ${total.toStringAsFixed(2)}'),
            ],
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.sharePdf(bytes: pdfBytes, filename: '$storeName.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerador de Mini-nota')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedProduct,
                    isExpanded: true,
                    items:
                        predefinedProducts.keys
                            .map(
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Text(key),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => selectedProduct = v),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: selectedQuantity,
                  items:
                      quantities
                          .map(
                            (q) =>
                                DropdownMenuItem(value: q, child: Text('$q')),
                          )
                          .toList(),
                  onChanged: (q) => setState(() => selectedQuantity = q!),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addPredefinedItem,
                  child: const Text('Adicionar Padrão'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Produto'),
            ),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Valor Unitário'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addItem,
              child: const Text('Adicionar Produto'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      'Qtd: ${item.quantity}  V.Unit: ${item.unitPrice.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removeItem(index),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(item.sum.toStringAsFixed(2)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Text(
              'Total: ${total.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: generatePdfAndShare,
              child: const Text('Gerar PDF e Compartilhar'),
            ),
          ],
        ),
      ),
    );
  }
}
