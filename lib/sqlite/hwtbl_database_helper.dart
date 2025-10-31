// import 'package:path/path.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class HWDB {
//   static final HWDB instance = HWDB._init();
//   static Database? _database;

//   HWDB._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('hw.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);

//     return await openDatabase(path, version: 1, onCreate: _createDB);
//   }

//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE HW(
//         HWID INTEGER PRIMARY KEY AUTOINCREMENT,
//         HWPersNo INTEGER NOT NULL,
//         DOAppt TEXT,
//         ExtnUpto TEXT,
//         DORelq TEXT,
//         CauseOfRelq TEXT,
//         AOR TEXT,
//         Checked TEXT,
//         PageNo TEXT,
//         HWRemarks TEXT,
//         Pic TEXT,
//         AccountNo INTEGER,
//         FOREIGN KEY (HWPersNo) REFERENCES BasicTbl(PersonalNo)
//       )
//     ''');
//   }

//   // Insert a record
//   Future<int> insertHW(Map<String, dynamic> row) async {
//     final db = await instance.database;
//     return await db.insert('HW', row);
//   }

//   // Update a record by HWID
//   Future<int> updateHW(int hwId, Map<String, dynamic> row) async {
//     final db = await instance.database;
//     return await db.update('HW', row, where: 'HWID = ?', whereArgs: [hwId]);
//   }

//   // Delete a record by HWID
//   Future<int> deleteHW(int hwId) async {
//     final db = await instance.database;
//     return await db.delete('HW', where: 'HWID = ?', whereArgs: [hwId]);
//   }

//   // Get all HW records for a specific person
//   Future<List<Map<String, dynamic>>> getHWsByPerson(int persNo) async {
//     final db = await instance.database;
//     return await db.query('HW', where: 'HWPersNo = ?', whereArgs: [persNo]);
//   }

//   // Get a single record by HWID
//   Future<Map<String, dynamic>?> getHW(int hwId) async {
//     final db = await instance.database;
//     final res = await db.query('HW', where: 'HWID = ?', whereArgs: [hwId]);
//     if (res.isNotEmpty) return res.first;
//     return null;
//   }

//   // Get all HW records
//   Future<List<Map<String, dynamic>>> getAllHWs() async {
//     final db = await instance.database;
//     return await db.query('HW');
//   }

//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }
// }
