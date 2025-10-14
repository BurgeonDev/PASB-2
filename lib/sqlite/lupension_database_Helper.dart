import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LuPensionDatabase {
  static final LuPensionDatabase instance = LuPensionDatabase._init();
  static Database? _database;

  LuPensionDatabase._init();

  // Initialize or return existing database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lupension.db');
    return _database!;
  }

  // Open or create the database
  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
    );
  }

  // Create the 'LuPension' table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE LuPension (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Pension_Type TEXT NOT NULL,
        Pension_Category TEXT NOT NULL,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT
      )
    ''');
  }

  // Insert a new record
  Future<int> insertPension(Map<String, dynamic> data) async {
    final db = await instance.database;

    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    return await db.insert('LuPension', data);
  }

  // Get all records
  Future<List<Map<String, dynamic>>> getAllPensions() async {
    final db = await instance.database;
    return await db.query('LuPension', orderBy: 'id DESC');
  }

  // Get a record by ID
  Future<Map<String, dynamic>?> getPensionById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'LuPension',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Update a record
  Future<int> updatePension(Map<String, dynamic> data) async {
    final db = await instance.database;

    data['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      'LuPension',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // Delete a record
  Future<int> deletePension(int id) async {
    final db = await instance.database;
    return await db.delete('LuPension', where: 'id = ?', whereArgs: [id]);
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
