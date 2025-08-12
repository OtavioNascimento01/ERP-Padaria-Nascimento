import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroRotinaPage extends StatefulWidget {
  const CadastroRotinaPage({Key? key}) : super(key: key);

  @override
  State<CadastroRotinaPage> createState() => _CadastroRotinaPageState();
}

class _CadastroRotinaPageState extends State<CadastroRotinaPage> {
  final Color backgroundColor = Color.fromARGB(255, 189, 235, 255);
  final Color cardColor = Colors.white;
  final Color primaryColor = Color.fromARGB(255, 4, 43, 74);
  final Color fontColor = Color.fromARGB(255, 4, 43, 74);
  final Color lightFontColor = Colors.white;

  final List<String> diasSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  String diaSelecionado = 'Segunda-feira';
  final Map<String, TextEditingController> rotinaControllers = {};

  @override
  void initState() {
    super.initState();
    for (var dia in diasSemana) {
      rotinaControllers[dia] = TextEditingController();
    }
    _carregarRotinas();
  }

  @override
  void dispose() {
    for (var ctrl in rotinaControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarRotinas() async {
    final prefs = await SharedPreferences.getInstance();
    for (var dia in diasSemana) {
      rotinaControllers[dia]?.text = prefs.getString('rotina_$dia') ?? '';
    }
    setState(() {});
  }

  Future<void> salvarRotina() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'rotina_$diaSelecionado',
      rotinaControllers[diaSelecionado]?.text ?? '',
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rotina salva para $diaSelecionado')),
    );
  }

  Future<void> limparRotina() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rotina_$diaSelecionado');
    rotinaControllers[diaSelecionado]?.clear();
    setState(() {});
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Selecione o dia da semana",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: fontColor,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                isExpanded: true,
                value: diaSelecionado,
                underline: SizedBox(),
                borderRadius: BorderRadius.circular(8),
                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                dropdownColor: cardColor,
                style: TextStyle(color: fontColor, fontSize: 17),
                items:
                    diasSemana
                        .map(
                          (dia) =>
                              DropdownMenuItem(value: dia, child: Text(dia)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      diaSelecionado = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 18),
            Expanded(
              child: Container(
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
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      diaSelecionado,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fontColor,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: rotinaControllers[diaSelecionado],
                        minLines: 6,
                        maxLines: 12,
                        style: TextStyle(color: fontColor, fontSize: 16),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Digite sua rotina ou lembretes...',
                          hintStyle: TextStyle(
                            color: fontColor.withOpacity(0.37),
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: limparRotina,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: fontColor,
                      padding: EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: primaryColor, width: 1),
                      ),
                      elevation: 0,
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
                  child: ElevatedButton(
                    onPressed: salvarRotina,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: lightFontColor,
                      padding: EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Salvar Rotina',
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
          ],
        ),
      ),
    );
  }
}
