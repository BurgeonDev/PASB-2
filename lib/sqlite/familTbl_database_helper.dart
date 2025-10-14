import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FamilyDB {
  static final FamilyDB instance = FamilyDB._init();
  static Database? _database;

  FamilyDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('family.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE FamilyTbl(
        NOKID INTEGER PRIMARY KEY AUTOINCREMENT,
        PersNo INTEGER NOT NULL,
        NOKName TEXT,
        NOKRelation TEXT,
        NOKDOB TEXT,
        NOKDOD TEXT,
        NOKDOM TEXT,
        NOKEdn TEXT,
        NOKProfession TEXT,
        NOKMaritialStatus TEXT,
        NOKDisability TEXT,
        NOKCNIC TEXT,
        NOKIDMks TEXT,
        NOKMobileNo TEXT,
        NOKSourceOfIncome TEXT,
        NOKMonthlyIncome INTEGER,
        NOKDODivorced TEXT,
        AmountChildrenAllce INTEGER,
        DOChildrenAllce TEXT,
        NOKRemarks TEXT,
        NOKPSBNo TEXT,
        NOKPPONo TEXT,
        NOKGPO TEXT,
        NOKPDO TEXT,
        NOKNetPension INTEGER,
        NOKBankName TEXT,
        NOKBankBranch TEXT,
        NOKBankCode TEXT,
        NOKBankAcctNo TEXT,
        NOKIBANNo TEXT,
        DCSStartMonth TEXT,
        NOKTypeOfPension TEXT,
        FOREIGN KEY (PersNo) REFERENCES BasicTbl(PersonalNo)
      )
    ''');
  }

  // Insert a NOK record
  Future<int> insertNOK(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('FamilyTbl', row);
  }

  // Update a NOK record by NOKID
  Future<int> updateNOK(int nokId, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'FamilyTbl',
      row,
      where: 'NOKID = ?',
      whereArgs: [nokId],
    );
  }

  // Delete a NOK record by NOKID
  Future<int> deleteNOK(int nokId) async {
    final db = await instance.database;
    return await db.delete('FamilyTbl', where: 'NOKID = ?', whereArgs: [nokId]);
  }

  // Get all NOKs for a specific person
  Future<List<Map<String, dynamic>>> getNOKsByPerson(int persNo) async {
    final db = await instance.database;
    return await db.query(
      'FamilyTbl',
      where: 'PersNo = ?',
      whereArgs: [persNo],
    );
  }

  // Get a single NOK by NOKID
  Future<Map<String, dynamic>?> getNOK(int nokId) async {
    final db = await instance.database;
    final res = await db.query(
      'FamilyTbl',
      where: 'NOKID = ?',
      whereArgs: [nokId],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // all data
  Future<List<Map<String, dynamic>>> getAllNOKs() async {
    final db = await instance.database;
    return await db.query('FamilyTbl');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
