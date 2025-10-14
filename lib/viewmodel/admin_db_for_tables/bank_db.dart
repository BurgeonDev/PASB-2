import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BankDB {
  static final BankDB instance = BankDB._init();
  static Database? _database;

  BankDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('banks_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final directory = Directory.current;
    final path = join(directory.path, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lu_bank(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        abbreviation TEXT NOT NULL,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<int> insertBank(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('lu_bank', data);
  }

  Future<List<Map<String, dynamic>>> fetchBanks() async {
    final db = await instance.database;
    return await db.query('lu_bank', orderBy: 'id DESC');
  }

  Future<int> updateBank(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update('lu_bank', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBank(int id) async {
    final db = await instance.database;
    return await db.delete('lu_bank', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
