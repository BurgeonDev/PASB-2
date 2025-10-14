import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PensionDB {
  static final PensionDB instance = PensionDB._init();
  static Database? _database;

  PensionDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pension.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE PensionTbl (
        FPID INTEGER PRIMARY KEY AUTOINCREMENT,
        PenExNo TEXT,
        Status INTEGER,
        PenDOEntry TEXT,
        RegSerNo INTEGER,
        GpInsuranceClaimLtrDate TEXT,
        BenFundClaimLtrNo TEXT,
        BenFundClaimLtrDate TEXT,
        DASBLtrNo TEXT,
        DASBLtrDate TEXT,
        FinalizedDate TEXT,
        ParticularsOfHWO TEXT,
        Originator TEXT,
        OriginatorLtrNo TEXT,
        OriginatorLtrDate TEXT,
        OriginatorResponse TEXT,
        History TEXT,
        PensionCaseRemarks TEXT,
        VerifiedBy INTEGER,
        FirstWitness INTEGER,
        SecondWitness INTEGER,
        DOMarriage TEXT,
        NextNOKName TEXT,
        NextNOKRelation TEXT,
        NextNOKCNICNo TEXT,
        UrduName TEXT,
        UrduFatherName TEXT,
        UrduNOKName TEXT,
        UrduNextNOKName TEXT,
        UrduNextNOKRelation TEXT,
        UrduRelation TEXT,
        UrduVillage TEXT,
        UrduPostOffice TEXT,
        UrduTeh TEXT,
        UrduDistt TEXT,
        UrduPresentAddress TEXT,
        FOREIGN KEY (Status) REFERENCES BasicTbl(PersonalNo),
        FOREIGN KEY (RegSerNo) REFERENCES BasicTbl(PersonalNo),
        FOREIGN KEY (VerifiedBy) REFERENCES BasicTbl(PersonalNo),
        FOREIGN KEY (FirstWitness) REFERENCES BasicTbl(PersonalNo),
        FOREIGN KEY (SecondWitness) REFERENCES BasicTbl(PersonalNo)
      )
    ''');
  }

  // Insert a record
  Future<int> insertPension(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('PensionTbl', row);
  }

  // Update a record by FPID
  Future<int> updatePension(int fpid, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'PensionTbl',
      row,
      where: 'FPID = ?',
      whereArgs: [fpid],
    );
  }

  // Delete a record by FPID
  Future<int> deletePension(int fpid) async {
    final db = await instance.database;
    return await db.delete('PensionTbl', where: 'FPID = ?', whereArgs: [fpid]);
  }

  // Get a single record by FPID
  Future<Map<String, dynamic>?> getPension(int fpid) async {
    final db = await instance.database;
    final res = await db.query(
      'PensionTbl',
      where: 'FPID = ?',
      whereArgs: [fpid],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // Get all records
  Future<List<Map<String, dynamic>>> getAllPensions() async {
    final db = await instance.database;
    return await db.query('PensionTbl');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
