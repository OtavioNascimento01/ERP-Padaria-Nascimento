import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'pages/home_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/nova_venda.dart';
import 'pages/cadastro_rotina.dart';
import 'pages/cadastro_produto.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'erp_padaria.db');
  await deleteDatabase(path); // Isso APAGA o banco antigo!
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color background = Color(0xFFEEEEFF);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu Inicial',
      theme: ThemeData(
        primaryColor: Color(0xFF28587B),
        scaffoldBackgroundColor: background,
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF28587B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 18),
            padding: EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ),
      home: HomePage(),
      routes: {
        '/dashboards': (context) => DashboardPage(),
        '/nova-venda': (context) => NovaVendaPage(),
        '/cadastro-rotina': (context) => CadastroRotinaPage(),
        '/cadastro-produto': (context) => CadastroProdutoPage(),
      },
    );
  }
}
