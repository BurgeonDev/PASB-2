import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LuRegtCorpsDatabase {
  static final LuRegtCorpsDatabase instance = LuRegtCorpsDatabase._init();
  static Database? _database;

  LuRegtCorpsDatabase._init();

  // Initialize or return existing database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('luregtcorps.db');
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

  // Create the 'Lu_Regt_Corps' table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Lu_Regt_Corps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        force TEXT NOT NULL,
        regtcorps TEXT NOT NULL,
        rw_phone TEXT,
        rw_address TEXT,
        rw_address_urdu TEXT,
        regt_urdu TEXT,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT
      )
    ''');
  }

  // Insert a new record
  Future<int> insertRegtCorps(Map<String, dynamic> data) async {
    final db = await instance.database;

    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    return await db.insert('Lu_Regt_Corps', data);
  }

  // Get all records
  Future<List<Map<String, dynamic>>> getAllRegtCorps() async {
    final db = await instance.database;
    return await db.query('Lu_Regt_Corps', orderBy: 'id DESC');
  }

  // Get a record by ID
  Future<Map<String, dynamic>?> getRegtCorpsById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'Lu_Regt_Corps',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Update a record
  Future<int> updateRegtCorps(Map<String, dynamic> data) async {
    final db = await instance.database;

    data['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      'Lu_Regt_Corps',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // Delete a record
  Future<int> deleteRegtCorps(int id) async {
    final db = await instance.database;
    return await db.delete('Lu_Regt_Corps', where: 'id = ?', whereArgs: [id]);
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
