import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:testing_window_app/model/account_model.dart';

class DatabaseHelper {
  final databaseName = 'saufiktechnology.db';

  String accountTbl = '''
CREATE TABLE accounts(
   accId INTEGER PRIMARY KEY AUTOINCREMENT,
   accHolder TEXT NOT NULL,
   accName TEXT NOT NULL,
   accStatus INTEGER,
   accCreatedAt TEXT
)
''';

  Future<Database> init() async {
    final databasePath = await getApplicationDocumentsDirectory();
    final path = '${databasePath.path}/$databaseName';
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(accountTbl);
      },
    );
  }

  // CRUD Methods

  // get
  Future<List<AccountJson>> getAccounts() async {
    final Database db = await init();
    List<Map<String, Object?>> result = await db.query(
      'accounts',
      where: 'accStatus=1',
    );
    return result.map((e) => AccountJson.fromJson(e)).toList();
  }

  // insert
  Future<int> inserAccount(AccountJson account) async {
    final Database db = await init();
    return db.insert('accounts', account.toJson());
  }

  // upadate

  Future<int> updateAccount(String accHolder, String accName, int id) async {
    final Database db = await init();
    return db.rawUpdate('update set accHolder = ?, accName = ? where accId', [
      accHolder,
      accName,
      id,
    ]);
  }

  // delete
  Future<int> deleteAccount(int id) async {
    final Database db = await init();
    return db.delete('accounts', where: 'accId==?', whereArgs: [id]);
  }
}
