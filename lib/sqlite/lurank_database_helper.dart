import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class RankDatabase {
  static final RankDatabase instance = RankDatabase._init();
  static Database? _database;

  RankDatabase._init();

  // Initialize or return existing database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rank.db');
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
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  // Create the 'rank' table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rank (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rank TEXT NOT NULL,
        acronym TEXT,
        forces TEXT NOT NULL,
        rank_category TEXT NOT NULL,
        rank_urdu TEXT,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT
      )
    ''');
  }

  // Insert a new record
  Future<int> insertRank(Map<String, dynamic> data) async {
    final db = await instance.database;

    // ✅ Add timestamps automatically
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    return await db.insert('rank', data);
  }

  // Get all records
  Future<List<Map<String, dynamic>>> getAllRanks() async {
    final db = await instance.database;
    return await db.query('rank', orderBy: 'id DESC');
  }

  // Get a record by ID
  Future<Map<String, dynamic>?> getRankById(int id) async {
    final db = await instance.database;
    final result = await db.query('rank', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Update a record
  Future<int> updateRank(Map<String, dynamic> data) async {
    final db = await instance.database;

    // ✅ Update timestamp automatically
    data['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      'rank',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // Delete a record
  Future<int> deleteRank(int id) async {
    final db = await instance.database;
    return await db.delete('rank', where: 'id = ?', whereArgs: [id]);
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
