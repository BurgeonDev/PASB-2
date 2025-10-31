import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AdminDB {
  static final AdminDB instance = AdminDB._init();
  static Database? _database;

  AdminDB._init();

  // Get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('admin_data.db');
    return _database!;
  }

  // Initialize DB
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
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 3, // increment when adding new tables
      onCreate: _createDB,
    );
  }

  // CREATE ALL TABLES
  Future _createDB(Database db, int version) async {
    // ✅ Province Table
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

    // ✅ Directorate Table
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

    // ✅ DASB Table
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

    // ✅ District Table
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

    // ✅ Tehsil Table
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

    // ✅ UC Table
    await db.execute('''
      CREATE TABLE uc (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tehsil_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (tehsil_id) REFERENCES tehsil (id)
      );
    ''');

    // ✅ Lu_Regt_Corps Table
    await db.execute('''
      CREATE TABLE Lu_Regt_Corps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        force TEXT NOT NULL,
        regtcorps TEXT NOT NULL,
        rw_phone TEXT,
        rw_address TEXT,
        rw_address_urdu TEXT,
        regt_urdu TEXT,
        created_by TEXT,
        created_at TEXT,
        updated_by TEXT,
        updated_at TEXT
      )
    ''');

    // // ✅ NEW — Rank Table
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

    // ✅ LU_BANK Table
    await db.execute('''
  CREATE TABLE lu_bank(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    abbreviation TEXT NOT NULL,
    created_by TEXT,
    created_at TEXT,
    updated_by TEXT,
    updated_at TEXT
  )
''');

    // ✅ LU_PENSION Table
    await db.execute('''
  CREATE TABLE Lu_Pension (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    Pension_Type TEXT NOT NULL,
    Pension_Category TEXT NOT NULL,
    created_by TEXT,
    created_at TEXT,
    updated_by TEXT,
    updated_at TEXT
  )
''');

    // ✅ FamilyTbl (linked to BasicTbl.id)
    await db.execute('''
      CREATE TABLE FamilyTbl(
        NOKID INTEGER PRIMARY KEY AUTOINCREMENT,
        PersId INTEGER NOT NULL,
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
        FOREIGN KEY (PersId) REFERENCES basictbl(id) ON DELETE CASCADE
      )
    ''');

    // ✅ BasicTbl Table (linked to Lu_Regt_Corps)
    await db.execute('''
      CREATE TABLE basictbl (
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
        created_at TEXT,
      updated_at TEXT,
      created_by   TEXT,
      updated_by TEXT,
        dcs_start_month TEXT,
        last_modified_by TEXT,
        last_modified_date TEXT,
        regtcorps_id INTEGER,
        rank_id INTEGER,
        pension_id INTEGER,

bank_id INTEGER,
        FOREIGN KEY (regtcorps_id) REFERENCES Lu_Regt_Corps(id) ON DELETE SET NULL,
          FOREIGN KEY (rank_id) REFERENCES rank(id) ON DELETE SET NULL,
           FOREIGN KEY (bank_id) REFERENCES lu_bank(id) ON DELETE SET NULL,
           FOREIGN KEY (pension_id) REFERENCES Lu_Pension(id) ON DELETE SET NULL

      )
    ''');

    await db.execute('''
      CREATE TABLE pension_claims(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fromPerson TEXT,
        toPerson TEXT,
        pensionId TEXT,
        pensionNumber TEXT,
        claimant TEXT,
        relation TEXT,
        date TEXT,
        message TEXT,
        uploadedFileName TEXT,
        uploadedFilePath TEXT
      )
    ''');
  }

  // ✅ Insert Record
  Future<int> insertRecord(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    data['created_at'] ??= DateTime.now().toIso8601String();
    return await db.insert(table, data);
  }

  // ✅ Fetch All
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    final db = await instance.database;
    return await db.query(table, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> fetchAllWithJoins() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
    SELECT b.*, 
           r.regtcorps AS regt_name,
           rk.rank AS rank_name
    FROM basictbl b
    LEFT JOIN Lu_Regt_Corps r ON b.regt_id = r.id
    LEFT JOIN rank rk ON b.rank_id = rk.id
    ORDER BY b.id DESC
  ''');
    return result;
  }

  // ✅ Fetch records using a WHERE clause
  Future<List<Map<String, dynamic>>> fetchWhere(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    final db = await instance.database;
    return await db.query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );
  }

  // ✅ Update
  Future<int> updateRecord(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    final id = data['id'];
    data['updated_at'] = DateTime.now().toIso8601String();
    data.remove('id');
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Delete
  Future<int> deleteRecord(String table, int id) async {
    final db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- GET BY PERSONAL NO ----------------
  Future<Map<String, dynamic>?> getRecordByPersonalNo(String personalNo) async {
    final db = await instance.database;
    final result = await db.query(
      'basictbl',
      where: 'personal_no = ?',
      whereArgs: [personalNo],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ---------------- GET SHUHADA ----------------
  Future<List<Map<String, dynamic>>> getShuhada() async {
    final db = await instance.database;
    return await db.query(
      'basictbl',
      where: "do_death IS NOT NULL AND do_death != ''",
      orderBy: "id DESC",
    );
  }

  // ---------------- GET DISABLED ----------------
  Future<List<Map<String, dynamic>>> getDisabled() async {
    final db = await instance.database;
    return await db.query(
      'basictbl',
      where: """
        (do_disability IS NOT NULL AND do_disability != '')
        OR (nature_disability IS NOT NULL AND nature_disability != '')
      """,
      orderBy: "id DESC",
    );
  }

  // ✅ Close
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
