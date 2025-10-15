import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AdminDB {
  static final AdminDB instance = AdminDB._init();
  static Database? _database;

  AdminDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('admin_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory directory;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      directory = Directory.current;
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final path = join(directory.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE province(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE directorate(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        province_id INTEGER,
        name TEXT,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT,
        FOREIGN KEY (province_id) REFERENCES province (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE dasb(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        province_id INTEGER,
        directorate_id INTEGER,
        name TEXT,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT,
        FOREIGN KEY (province_id) REFERENCES province (id),
        FOREIGN KEY (directorate_id) REFERENCES directorate (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE district(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dasb_id INTEGER,
        name TEXT,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT,
        FOREIGN KEY (dasb_id) REFERENCES dasb (id)
      )
    ''');

    // ✅ TEHSIL TABLE
    await db.execute('''
      CREATE TABLE tehsil (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        district_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (district_id) REFERENCES district (id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
  CREATE TABLE IF NOT EXISTS uc (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tehsil_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    created_at TEXT,
    updated_at TEXT,
    FOREIGN KEY (tehsil_id) REFERENCES tehsil (id)
  );
''');
  }

  // ✅ Insert a new record
  Future<int> insertRecord(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(table, data);
  }

  // ✅ Fetch all records from a table
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  // ✅ Fetch records with WHERE condition
  Future<List<Map<String, dynamic>>> fetchWhere(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    final db = await instance.database;
    return await db.query(table, where: whereClause, whereArgs: whereArgs);
  }

  // ✅ Update record
  Future<int> updateRecord(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    if (!data.containsKey('id')) {
      throw ArgumentError('Missing "id" in data for updateRecord');
    }

    final id = data['id'];
    data.remove('id'); // remove id from data to avoid overwriting
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Delete record by id
  Future<int> deleteRecord(String table, int id) async {
    final db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
