import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BenDB {
  static final BenDB instance = BenDB._init();
  static Database? _database;

  BenDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ben_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory directory;

    // ✅ Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      directory = Directory.current; // Store DB in current directory
    } else {
      directory = await getApplicationDocumentsDirectory(); // Mobile
    }

    final path = join(directory.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Bentbl(
        BenID INTEGER PRIMARY KEY AUTOINCREMENT,
        BenPersNo TEXT,
        BenBankerName TEXT,
        BenBranchCode TEXT,
        BenBankAcctNo TEXT,
        BenBankIBANNo TEXT,
        BenRemarks TEXT,
        AmountReceived TEXT,
        AmountReceivedDate TEXT,
        MaritalStatus TEXT,
        DASBFileNo TEXT,
        BenOriginator TEXT,
        BenOriginatorLtrDate TEXT,
        BenOriginatorLtrNo TEXT,
        CaseReceivedForVerification TEXT,
        BenStatus TEXT,
        HWOConcerned TEXT
      )
    ''');
  }

  // ✅ Insert new record
  Future<int> insertBen(Map<String, dynamic> ben) async {
    final db = await instance.database;
    return await db.insert('Bentbl', ben);
  }

  // ✅ Get all records
  Future<List<Map<String, dynamic>>> getAllBens() async {
    final db = await instance.database;
    return await db.query('Bentbl');
  }

  // ✅ Update a record
  Future<int> updateBen(int id, Map<String, dynamic> ben) async {
    final db = await instance.database;
    return await db.update('Bentbl', ben, where: 'BenID = ?', whereArgs: [id]);
  }

  // ✅ Delete a record
  Future<int> deleteBen(int id) async {
    final db = await instance.database;
    return await db.delete('Bentbl', where: 'BenID = ?', whereArgs: [id]);
  }

  // ✅ Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> delete(int id) async {}
}
