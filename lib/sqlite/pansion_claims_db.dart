// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class PensionClaimsDB {
//   static final PensionClaimsDB instance = PensionClaimsDB._init();
//   static Database? _database;

//   PensionClaimsDB._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('pension_claims.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     Directory directory;

//     // ✅ Initialize FFI for desktop platforms
//     if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
//       sqfliteFfiInit();
//       databaseFactory = databaseFactoryFfi;
//       directory = Directory.current; // Save DB in current working folder
//     } else {
//       directory = await getApplicationDocumentsDirectory(); // Mobile support
//     }

//     final path = join(directory.path, filePath);
//     return await openDatabase(path, version: 1, onCreate: _createDB);
//   }

//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE pension_claims(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         fromPerson TEXT,
//         toPerson TEXT,
//         pensionId TEXT,
//         pensionNumber TEXT,
//         claimant TEXT,
//         relation TEXT,
//         date TEXT,
//         message TEXT,
//         uploadedFileName TEXT,
//         uploadedFilePath TEXT
//       )
//     ''');
//   }

//   Future<int> insertClaim(Map<String, dynamic> claim) async {
//     final db = await instance.database;
//     return await db.insert('pension_claims', claim);
//   }

//   Future<List<Map<String, dynamic>>> getAllClaims() async {
//     final db = await instance.database;
//     return await db.query('pension_claims');
//   }

//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }
// }
