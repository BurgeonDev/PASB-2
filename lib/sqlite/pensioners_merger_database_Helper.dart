import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PensionMergerDB {
  static final PensionMergerDB instance = PensionMergerDB._init();
  static Database? _database;

  PensionMergerDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pension_merger.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    sqfliteFfiInit(); // ✅ Required for Windows/Linux/Mac
    databaseFactory = databaseFactoryFfi;

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE PensionMergerTbl (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,

        -- 🔹 Foreign Key
        PersNo INTEGER,

        -- 🔹 Particulars of Deceased
        Rank TEXT,
        Name TEXT,
        FatherName TEXT,
        RegtCorps TEXT,
        DateOfDisch TEXT,
        DateOfDeath TEXT,
        PlaceOfDeath TEXT,
        CauseOfDeath TEXT,
        CNIC TEXT,
        Village TEXT,
        PostOffice TEXT,
        Tehsil TEXT,
        District TEXT,
        PresentAddress TEXT,

        -- 🔹 Urdu Fields
        UrduName TEXT,
        UrduFatherName TEXT,
        UrduVillage TEXT,
        UrduPostOffice TEXT,
        UrduTehsil TEXT,
        UrduDistrict TEXT,
        UrduNOKName TEXT,
        UrduNOKRelation TEXT,

        -- 🔹 Next of Kin
        PensionType TEXT,
        NOKName TEXT,
        Relation TEXT,
        DateOfBirth TEXT,
        DateOfMarriage TEXT,
        NOKCNIC TEXT,
        MobileNo TEXT,
        IDMarks TEXT,
        NextNOKName TEXT,
        NextNOKRelation TEXT,
        NextNOKCNIC TEXT,
        GenRemarks TEXT,
        DASBLtrNo TEXT,
        DASBLtrDate TEXT,

        FOREIGN KEY (PersNo) REFERENCES BasicTbl(PersonalNo)
      )
    ''');
  }

  // 🔹 Insert Record
  Future<int> insertMerger(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('PensionMergerTbl', row);
  }

  // 🔹 Update Record by ID
  Future<int> updateMerger(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'PensionMergerTbl',
      row,
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  // 🔹 Delete Record by ID
  Future<int> deleteMerger(int id) async {
    final db = await instance.database;
    return await db.delete(
      'PensionMergerTbl',
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  // 🔹 Get Single Record
  Future<Map<String, dynamic>?> getMerger(int id) async {
    final db = await instance.database;
    final res = await db.query(
      'PensionMergerTbl',
      where: 'ID = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // 🔹 Get All Records
  Future<List<Map<String, dynamic>>> getAllMergers() async {
    final db = await instance.database;
    return await db.query('PensionMergerTbl');
  }

  // 🔹 Close Database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
