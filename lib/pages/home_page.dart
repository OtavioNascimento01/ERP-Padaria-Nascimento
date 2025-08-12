import 'package:flutter/material.dart';
import 'cadastro_produto.dart';
import 'cadastro_rotina.dart';
import 'cadastro_pessoa.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String rotinaHoje = '';
  String diaSemanaHoje = '';

  final Color backgroundColor = Color.fromARGB(255, 189, 235, 255);
  final Color primaryColor = Color.fromARGB(255, 4, 43, 74);
  final Color cardColor = Color.fromARGB(255, 255, 255, 255);
  final Color fontColor = Color.fromARGB(255, 4, 43, 74);
  final Color lightFontColor = Colors.white;

  @override
  void initState() {
    super.initState();
    carregarRotinaDoDia();
  }

  Future<void> carregarRotinaDoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final diasDaSemana = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    final hoje = DateTime.now();
    // weekday: 1 (segunda-feira) ... 7 (domingo)
    final indice = hoje.weekday == 7 ? 6 : hoje.weekday - 1;
    final nomeDia = diasDaSemana[indice];
    final rotina = prefs.getString('rotina_$nomeDia') ?? '';
    setState(() {
      rotinaHoje = rotina;
      diaSemanaHoje = nomeDia;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "ERP Padaria Nascimento",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: Drawer(
        child: Container(
          color: backgroundColor,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: primaryColor),
                child: Center(
                  child: Text(
                    "ERP Padaria Nascimento",
                    style: TextStyle(
                      color: lightFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ExpansionTile(
                title: Text(
                  "Cadastros",
                  style: TextStyle(
                    color: fontColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: Icon(Icons.folder_open, color: fontColor),
                children: [
                  ListTile(
                    title: Text(
                      "Cadastro de Pessoa",
                      style: TextStyle(color: fontColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CadastroPessoaPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Cadastro de Produto",
                      style: TextStyle(color: fontColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CadastroProdutoPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Cadastro de Rotina",
                      style: TextStyle(color: fontColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CadastroRotinaPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: fontColor),
                title: Text(
                  "Dashboards",
                  style: TextStyle(
                    color: fontColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/dashboards');
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de rotina do dia (idêntico ao de cadastro)
              Container(
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
                margin: EdgeInsets.only(bottom: 24),
                height: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      diaSemanaHoje.isEmpty ? 'Hoje' : diaSemanaHoje,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fontColor,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          rotinaHoje.isEmpty
                              ? 'Nenhuma rotina cadastrada para hoje.'
                              : rotinaHoje,
                          style: TextStyle(color: fontColor, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botão - Nova Venda
              _menuButton(
                context,
                label: 'Nova Venda',
                onTap: () => Navigator.pushNamed(context, '/nova-venda'),
                color: primaryColor,
                textColor: lightFontColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return SizedBox(
      height: 68,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
          elevation: 2,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
