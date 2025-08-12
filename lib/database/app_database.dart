import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  static Database? _database;

  AppDatabase._();

  factory AppDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'erp_padaria.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela Pessoa
    await db.execute('''
      CREATE TABLE pessoas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        fantasia TEXT,
        documento TEXT,
        tipo TEXT,
        endereco TEXT
      )
    ''');

    // Tabela Produto
    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        custo_unitario REAL,
        vl_venda_unitario REAL,
        fk_fornecedor INTEGER,
        FOREIGN KEY (fk_fornecedor) REFERENCES pessoas(id)
      )
    ''');

    // Tabela Venda
    await db.execute('''
      CREATE TABLE vendas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_cliente INTEGER,
        data_venda TEXT NOT NULL,
        vl_total REAL,
        FOREIGN KEY (fk_cliente) REFERENCES pessoas(id)
      )
    ''');

    // Tabela ItemVenda (relacionamento entre Venda e Produto)
    await db.execute('''
      CREATE TABLE itens_venda (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_venda INTEGER NOT NULL,
        fk_produto INTEGER NOT NULL,
        quantidade INTEGER NOT NULL,
        vl_venda_unitario REAL NOT NULL,
        vl_total_item REAL,
        FOREIGN KEY (fk_venda) REFERENCES vendas(id),
        FOREIGN KEY (fk_produto) REFERENCES produtos(id)
      )
    ''');
  }
}
