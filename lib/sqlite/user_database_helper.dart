import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper2 {
  static final DatabaseHelper2 instance = DatabaseHelper2._internal();
  static Database? _database;

  DatabaseHelper2._internal();

  final String tableName = "basictbl";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'BasicTbl.db');
    print('Database is stored at: $path');
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: _createTables,
        onUpgrade: _addMissingColumns,
      ),
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_entry TEXT,
        prefix TEXT,
        personal_no TEXT,
        rank TEXT,
        trade TEXT,
        name TEXT,
        regt TEXT,
        type_of_pension TEXT,
        parent_unit TEXT,
        nok_name TEXT,
        nok_relation TEXT,
        village TEXT,
        post_office TEXT,
        uc_name TEXT,
        tehsil TEXT,
        district TEXT,
        present_addr TEXT,
        mobile TEXT,
        honours TEXT,
        war_ops TEXT,
        civil_edn TEXT,
        mil_qual TEXT,
        med_cat TEXT,
        dob TEXT,
        do_enlt TEXT,
        do_disch TEXT,
        cause_disch TEXT,
        do_death TEXT,
        cause_death TEXT,
        character TEXT,
        cl_disability TEXT,
        do_disability TEXT,
        nature_disability TEXT,
        cause_disability TEXT,
        cnic TEXT,
        cmp_cnic_no TEXT,
        id_marks TEXT,
        railway_station TEXT,
        police_station TEXT,
        place_death TEXT,
        citation_shaheed TEXT,
        loc_graveyard TEXT,
        tomb_stone TEXT,
        father_name TEXT,
        gpo TEXT,
        pdo TEXT,
        psb_no TEXT,
        ppo_no TEXT,
        bank_name TEXT,
        bank_branch TEXT,
        bank_acct_no TEXT,
        iban_no TEXT,
        nok_cnic TEXT,
        nok_do_birth TEXT,
        nok_id_mks TEXT,
        nok_gpo TEXT,
        nok_pdo TEXT,
        nok_psb_no TEXT,
        nok_ppo_no TEXT,
        nok_bank_name TEXT,
        nok_bank_branch TEXT,
        nok_bank_acct_no TEXT,
        nok_iban_no TEXT,
        net_pension TEXT,
        nok_net_pension TEXT,
        register_page TEXT,
        shaheed_remarks TEXT,
        disable_remarks TEXT,
        gen_remarks TEXT,
        dasb TEXT,
        date_verification TEXT,
        source_verification TEXT,
        dcs_start_month TEXT,
        last_modified_by TEXT,
        last_modified_date TEXT
      )
    ''');
  }

  Future<void> _addMissingColumns(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    final existingColumns = (await db.rawQuery(
      'PRAGMA table_info($tableName)',
    )).map((col) => col['name'] as String).toSet();

    final allColumns = [
      'date_entry',
      'prefix',
      'personal_no',
      'rank',
      'trade',
      'name',
      'regt',
      'type_of_pension',
      'parent_unit',
      'nok_name',
      'nok_relation',
      'village',
      'post_office',
      'uc_name',
      'tehsil',
      'district',
      'present_addr',
      'mobile',
      'honours',
      'war_ops',
      'civil_edn',
      'mil_qual',
      'med_cat',
      'dob',
      'do_enlt',
      'do_disch',
      'cause_disch',
      'do_death',
      'cause_death',
      'character',
      'cl_disability',
      'do_disability',
      'nature_disability',
      'cause_disability',
      'cnic',
      'cmp_cnic_no',
      'id_marks',
      'railway_station',
      'police_station',
      'place_death',
      'citation_shaheed',
      'loc_graveyard',
      'tomb_stone',
      'father_name',
      'gpo',
      'pdo',
      'psb_no',
      'ppo_no',
      'bank_name',
      'bank_branch',
      'bank_acct_no',
      'iban_no',
      'nok_cnic',
      'nok_do_birth',
      'nok_id_mks',
      'nok_gpo',
      'nok_pdo',
      'nok_psb_no',
      'nok_ppo_no',
      'nok_bank_name',
      'nok_bank_branch',
      'nok_bank_acct_no',
      'nok_iban_no',
      'net_pension',
      'nok_net_pension',
      'register_page',
      'shaheed_remarks',
      'disable_remarks',
      'gen_remarks',
      'dasb',
      'date_verification',
      'source_verification',
      'dcs_start_month',
      'last_modified_by',
      'last_modified_date',
    ];

    for (final col in allColumns) {
      if (!existingColumns.contains(col)) {
        await db.execute('ALTER TABLE $tableName ADD COLUMN $col TEXT');
      }
    }
  }

  // 🔹 Insert
  Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    row["date_entry"] ??= DateTime.now().toIso8601String();
    return await db.insert(tableName, row);
  }

  // 🔹 Get All
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query(tableName, orderBy: "id DESC");
  }

  // 🔹 Update
  Future<int> update(Map<String, dynamic> row) async {
    final db = await database;
    int id = row["id"];
    return await db.update(tableName, row, where: "id = ?", whereArgs: [id]);
  }

  // 🔹 Delete
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  // 🔹 List of Shuhada
  Future<List<Map<String, dynamic>>> getShuhada() async {
    final db = await database;
    return await db.query(
      tableName,
      where: "do_death IS NOT NULL AND do_death != ''",
      orderBy: "id DESC",
    );
  }

  // 🔹 List of Disabled
  Future<List<Map<String, dynamic>>> getDisabled() async {
    final db = await database;
    return await db.query(
      tableName,
      where:
          "(do_disability IS NOT NULL AND do_disability != '') "
          "OR (nature_disability IS NOT NULL AND nature_disability != '')",
      orderBy: "id DESC",
    );
  }

  // 🔹 Get by personal_no
  Future<Map<String, dynamic>?> getRecordByPersonalNo(String personalNo) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'personal_no = ?',
      whereArgs: [personalNo],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}
