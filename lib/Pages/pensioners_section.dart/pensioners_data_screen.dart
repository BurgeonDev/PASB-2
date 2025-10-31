import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_window_app/components/date_picker.dart';
import 'package:testing_window_app/components/textfield_component.dart';
import 'package:testing_window_app/components/toast_message.dart';
import 'package:testing_window_app/sqlite/user_database_helper.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class PensionersDataScreen extends StatefulWidget {
  final Map<String, dynamic>? pensionData;
  const PensionersDataScreen({super.key, this.pensionData});
  @override
  State<PensionersDataScreen> createState() => _PensionersDataState();
}

class _PensionersDataState extends State<PensionersDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController prefixController = TextEditingController();
  final TextEditingController personalNoController = TextEditingController();
  final TextEditingController tradeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController parentUnitController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController doEnltController = TextEditingController();
  final TextEditingController doDischController = TextEditingController();
  final TextEditingController honoursController = TextEditingController();
  final TextEditingController civilEdnController = TextEditingController();
  final TextEditingController causeDischController = TextEditingController();

  final TextEditingController villageController = TextEditingController();
  final TextEditingController postOfficeController = TextEditingController();
  final TextEditingController presentAddrController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController nokNameController = TextEditingController();
  final TextEditingController nokCnicController = TextEditingController();

  // for date
  final TextEditingController doDeathController = TextEditingController();
  DateTime? selectedDate;
  bool showCalendar = false;

  final TextEditingController placeDeathController = TextEditingController();
  final TextEditingController causeDeathController = TextEditingController();
  final TextEditingController locGraveyardController = TextEditingController();
  final TextEditingController doDisabilityController = TextEditingController();
  final TextEditingController natureDisabilityController =
      TextEditingController();
  final TextEditingController clDisabilityController = TextEditingController();
  final TextEditingController genRemarksController = TextEditingController();
  final TextEditingController doVerificationController =
      TextEditingController();

  // Bank & Pension Details
  final TextEditingController gpoController = TextEditingController();
  final TextEditingController pdoController = TextEditingController();
  final TextEditingController psbNoController = TextEditingController();
  final TextEditingController ppoNoController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController bankBranchController = TextEditingController();
  final TextEditingController bankAcctNoController = TextEditingController();
  final TextEditingController ibanNoController = TextEditingController();
  final TextEditingController netPensionController = TextEditingController();
  final TextEditingController registerPageController = TextEditingController();

  // NOK / Nominee Section
  final TextEditingController nokDoBirthController = TextEditingController();
  final TextEditingController nokIdMksController = TextEditingController();
  final TextEditingController nokGpoController = TextEditingController();
  final TextEditingController nokPdoController = TextEditingController();
  final TextEditingController nokPsbNoController = TextEditingController();
  final TextEditingController nokPpoNoController = TextEditingController();
  final TextEditingController nokBankNameController = TextEditingController();
  final TextEditingController nokBankBranchController = TextEditingController();
  final TextEditingController nokBankAcctNoController = TextEditingController();
  final TextEditingController nokIbanNoController = TextEditingController();
  final TextEditingController nokNetPensionController = TextEditingController();

  // Shuhada / Disabled & Verification
  final TextEditingController causeDisabilityController =
      TextEditingController();
  final TextEditingController citationShaheedController =
      TextEditingController();
  final TextEditingController tombStoneController = TextEditingController();
  final TextEditingController shaheedRemarksController =
      TextEditingController();
  final TextEditingController disableRemarksController =
      TextEditingController();
  final TextEditingController dateVerificationController =
      TextEditingController();
  final TextEditingController sourceVerificationController =
      TextEditingController();
  final TextEditingController dcsStartMonthController = TextEditingController();
  final TextEditingController lastModifiedByController =
      TextEditingController();
  final TextEditingController lastModifiedDateController =
      TextEditingController();

  // Additional Home/Misc fields
  final TextEditingController cmpCnicController = TextEditingController();
  final TextEditingController idMarksController = TextEditingController();
  final TextEditingController railwayStationController =
      TextEditingController();
  final TextEditingController policeStationController = TextEditingController();
  final TextEditingController milQualController = TextEditingController();

  // Dropdown-selected values
  int? selectedRankId;
  String? selectedPrefix;
  String? selectedForce;
  int? selectedTypeOfPensionId;
  String? selectedTypeOfPensionName;
  int? selectedBankId;
  int? selectedRegtId;
  String? selectedMedCat;
  String? selectedCharacter;

  String? selectedNOKRelation;
  String? selectedUCName;
  String? selectedTehsil;
  String? selectedDistrict;
  String? selectedWarOps;
  String? selectedDASB;
  String? selectedSourceVerification;

  // Sample lists (replace with your real options)

  final List<String> prefixOptions = [
    "tt",
    "PA-",
    "PSS-",
    "PJO-",
    "PTC-",
    "SR-",
    "PR-",
    "pak",
    "PTC",
    "NPO-",
  ];

  List<Map<String, dynamic>> rankList = [];
  List<Map<String, dynamic>> regtCorpsList = [];
  List<Map<String, dynamic>> bankList = [];
  List<Map<String, dynamic>> pensionTypes = [];

  Future<void> loadRegtCorps() async {
    try {
      // Use your unified database instance
      final db = await AdminDB.instance.database;

      // Debug: Check which tables exist
      var tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      print("Tables in DB: $tables");

      // ✅ Load the data from Lu_Regt_Corps
      final data = await AdminDB.instance.fetchAll('Lu_Regt_Corps');

      setState(() {
        regtCorpsList = data;
      });

      print("✅ Lu_Regt_Corps data loaded successfully: $regtCorpsList");
    } catch (e) {
      print("❌ Error fetching Lu_Regt_Corps: $e");
    }
  }

  final List<String> medCatOptions = ["A", "B", "C", "C (Perm)"];
  final List<String> characterOptions = [
    "Exemplary",
    "Good",
    "Satisfactory",
    "UnSatisfactory",
    "Very Good",
  ];

  final List<String> nokRelationOptions = [
    "Son",
    "Widow",
    "Father",
    "Mother",
    "Wife",
    "Sister",
    "Brother",
    "Daughter",
    "Legal Heirs",
    "More than one Nok",
  ];
  final List<String> ucNameOptions = ["UC-1", "UC-2", "UC-3"];
  final List<String> districtOptions = [
    "Lahore",
    "Karachi",
    "Islamabad",
    "Rawalpindi",
    "Faisalabad",
    "Multan",
    "Peshawar",
    "Quetta",
    "Sialkot",
    "Hyderabad",
  ];

  final List<String> tehsilOptions = [
    // Lahore District
    "Lahore City",
    "Model Town",
    "Cantt",
    "Raiwind",
    "Shalimar",
    // Rawalpindi District
    "Rawalpindi City",
    "Murree",
    "Taxila",
    "Gujar Khan",
    "Kahuta",
    // Faisalabad District
    "Faisalabad City",
    "Jaranwala",
    "Samundri",
    "Tandlianwala",
    "Chak Jhumra",
  ];

  final List<String> warOpsOptions = [
    "1947/48 War",
    "1965 War",
    "1971",
    "Misc",
    "ISD",
    "Op AlMizan",
  ];
  final List<String> dasbOptions = ["Rawalpindi"];
  final List<String> sourceVerificationOptions = [
    "CMP List",
    "PAFY-1923",
    "Visitor",
    'HWO',
  ];

  void _clearForm() {
    prefixController.clear();
    personalNoController.clear();
    tradeController.clear();
    nameController.clear();
    parentUnitController.clear();
    fatherNameController.clear();
    dobController.clear();
    doEnltController.clear();
    doDischController.clear();
    honoursController.clear();
    civilEdnController.clear();
    causeDischController.clear();
    villageController.clear();
    postOfficeController.clear();
    presentAddrController.clear();
    cnicController.clear();
    mobileController.clear();
    nokNameController.clear();
    nokCnicController.clear();
    doDeathController.clear();
    placeDeathController.clear();
    causeDeathController.clear();
    locGraveyardController.clear();
    doDisabilityController.clear();
    natureDisabilityController.clear();
    clDisabilityController.clear();
    genRemarksController.clear();
    doVerificationController.clear();

    setState(() {
      selectedRankId = null;
      selectedRegtId = null;
      selectedMedCat = null;
      selectedCharacter = null;
      selectedTypeOfPensionId = null;
      selectedNOKRelation = null;
      selectedUCName = null;
      selectedTehsil = null;
      selectedDistrict = null;
      selectedWarOps = null;
      selectedDASB = null;
      selectedSourceVerification = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Form cleared")));
  }

  @override
  void dispose() {
    prefixController.dispose();
    personalNoController.dispose();
    tradeController.dispose();
    nameController.dispose();
    parentUnitController.dispose();
    fatherNameController.dispose();
    dobController.dispose();
    doEnltController.dispose();
    doDischController.dispose();
    honoursController.dispose();
    civilEdnController.dispose();
    causeDischController.dispose();

    villageController.dispose();
    postOfficeController.dispose();
    presentAddrController.dispose();
    cnicController.dispose();
    mobileController.dispose();
    nokNameController.dispose();
    nokCnicController.dispose();

    doDeathController.dispose();
    placeDeathController.dispose();
    causeDeathController.dispose();
    locGraveyardController.dispose();
    doDisabilityController.dispose();
    natureDisabilityController.dispose();
    clDisabilityController.dispose();
    genRemarksController.dispose();
    doVerificationController.dispose();

    super.dispose();
  }

  Future<void> _saveDataToDb() async {
    Map<String, dynamic> row = {
      "date_entry": DateTime.now().toIso8601String(),
      "prefix": selectedPrefix,
      "personal_no": personalNoController.text,
      "rank": selectedRankId,
      "trade": tradeController.text,
      "name": nameController.text,
      "regt": selectedRegtId,
      "parent_unit": parentUnitController.text,
      "father_name": fatherNameController.text,
      "dob": dobController.text,
      "do_enlt": doEnltController.text,
      "do_disch": doDischController.text,
      "honours": honoursController.text,
      "civil_edn": civilEdnController.text,
      "med_cat": selectedMedCat,
      "character": selectedCharacter,
      "cause_disch": causeDischController.text,
      "village": villageController.text,
      "post_office": postOfficeController.text,
      "uc_name": selectedUCName,
      "tehsil": selectedTehsil,
      "district": selectedDistrict,
      "present_addr": presentAddrController.text,
      "cnic": cnicController.text,
      "mobile": mobileController.text,
      "nok_name": nokNameController.text,
      "nok_relation": selectedNOKRelation,
      "nok_cnic": nokCnicController.text,
      "type_of_pension": selectedTypeOfPensionId,
      "do_death": doDeathController.text,
      "place_death": placeDeathController.text,
      "cause_death": causeDeathController.text,
      "war_ops": selectedWarOps,
      "loc_graveyard": locGraveyardController.text,
      "do_disability": doDisabilityController.text,
      "nature_disability": natureDisabilityController.text,
      "cl_disability": clDisabilityController.text,
      "gen_remarks": genRemarksController.text,
      "dasb": selectedDASB,
      "source_verification": selectedSourceVerification,
      //  "do_verification": doVerificationController.text,
      "mil_qual": milQualController.text,
      "cmp_cnic_no": cmpCnicController.text,
      "id_marks": idMarksController.text,
      "railway_station": railwayStationController.text,
      "police_station": policeStationController.text,
      "cause_disability": causeDisabilityController.text,
      "citation_shaheed": citationShaheedController.text,
      "tomb_stone": tombStoneController.text,
      "shaheed_remarks": shaheedRemarksController.text,
      "disable_remarks": disableRemarksController.text,
      "date_verification": dateVerificationController.text,
      "source_verification": sourceVerificationController.text,
      "dcs_start_month": dcsStartMonthController.text,
      "last_modified_by": lastModifiedByController.text,
      "last_modified_date": lastModifiedDateController.text,
      "gpo": gpoController.text,
      "pdo": pdoController.text,
      "psb_no": psbNoController.text,
      "ppo_no": ppoNoController.text,
      "bank_name": bankNameController.text,
      "bank_branch": bankBranchController.text,
      "bank_acct_no": bankAcctNoController.text,
      "iban_no": ibanNoController.text,
      "net_pension": netPensionController.text,
      "register_page": registerPageController.text,
      "nok_do_birth": nokDoBirthController.text,
      "nok_id_mks": nokIdMksController.text,
      "nok_gpo": nokGpoController.text,
      "nok_pdo": nokPdoController.text,
      "nok_psb_no": nokPsbNoController.text,
      "nok_ppo_no": nokPpoNoController.text,
      "nok_bank_name": nokBankNameController.text,
      "nok_bank_branch": nokBankBranchController.text,
      "nok_bank_acct_no": nokBankAcctNoController.text,
      "nok_iban_no": nokIbanNoController.text,
      "nok_net_pension": nokNetPensionController.text,
    };

    try {
      final db = await AdminDB.instance.database;

      int id = await AdminDB.instance.insertRecord('basictbl', row);
      print("Inserted row id: $id");
    } catch (error) {
      print("Error inserting row: $error");
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.pensionData == null) {
      // ➕ New record
      await _saveDataToDb();
      ToastMessage.showSuccess(context, 'Data saved successfully!');
    } else {
      // ✏️ Edit existing record
      await _updateDataToDb(widget.pensionData!["id"]);
      ToastMessage.showSuccess(context, 'Data updated successfully!');
    }

    // Navigator.pop(context); // Go back to table screen
  }

  Future<void> _updateDataToDb(int id) async {
    Map<String, dynamic> updatedRow = {
      "id": id,
      "date_entry": DateTime.now().toIso8601String(),
      "prefix": selectedPrefix,
      "personal_no": personalNoController.text,
      "rank": selectedRankId,
      "trade": tradeController.text,
      "name": nameController.text,
      "regt": selectedRegtId,
      "parent_unit": parentUnitController.text,
      "father_name": fatherNameController.text,
      "dob": dobController.text,
      "do_enlt": doEnltController.text,
      "do_disch": doDischController.text,
      "honours": honoursController.text,
      "civil_edn": civilEdnController.text,
      "med_cat": selectedMedCat,
      "character": selectedCharacter,
      "cause_disch": causeDischController.text,
      "village": villageController.text,
      "post_office": postOfficeController.text,
      "uc_name": selectedUCName,
      "tehsil": selectedTehsil,
      "district": selectedDistrict,
      "present_addr": presentAddrController.text,
      "cnic": cnicController.text,
      "mobile": mobileController.text,
      "nok_name": nokNameController.text,
      "nok_relation": selectedNOKRelation,
      "nok_cnic": nokCnicController.text,
      "type_of_pension": selectedTypeOfPensionId,
      "do_death": doDeathController.text,
      "place_death": placeDeathController.text,
      "cause_death": causeDeathController.text,
      "war_ops": selectedWarOps,
      "loc_graveyard": locGraveyardController.text,
      "do_disability": doDisabilityController.text,
      "nature_disability": natureDisabilityController.text,
      "cl_disability": clDisabilityController.text,
      "gen_remarks": genRemarksController.text,
      "dasb": selectedDASB,
      "source_verification": selectedSourceVerification,
      "do_verification": doVerificationController.text,
    };

    try {
      await AdminDB.instance.updateRecord('basictbl', updatedRow);

      print("Updated record with ID: $id");
    } catch (error) {
      print("Error updating record: $error");
    }
  }

  String dateEntry = DateTime.now().toIso8601String(); // current date
  void _printAllData() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Map<String, String?> data = {
      "Date_Entry": dateEntry,
      "Prefix": selectedPrefix,
      "Personal No": personalNoController.text,
      "Rank": selectedRankId.toString(),
      "Trade": tradeController.text,
      "Name": nameController.text,
      "Regt/Corps": selectedRegtId.toString(),
      "Parent Unit": parentUnitController.text,
      "Father Name": fatherNameController.text,
      "DOB": dobController.text,
      "DO Enlist": doEnltController.text,
      "DO Discharge": doDischController.text,
      "Honours": honoursController.text,
      "Civil Edn": civilEdnController.text,
      "Med Category": selectedMedCat,
      "Character": selectedCharacter,
      "Cause Discharge": causeDischController.text,
      "Village": villageController.text,
      "Post Office": postOfficeController.text,
      "UC Name": selectedUCName,
      "Tehsil": selectedTehsil,
      "District": selectedDistrict,
      "Present Address": presentAddrController.text,
      "CNIC": cnicController.text,
      "Mobile": mobileController.text,
      "NOK Name": nokNameController.text,
      "NOK Relation": selectedNOKRelation,
      "NOK CNIC": nokCnicController.text,
      "Type of Pension": selectedTypeOfPensionId.toString(),
      "DO Death": doDeathController.text,
      "Place Death": placeDeathController.text,
      "Cause Death": causeDeathController.text,
      "War/Ops": selectedWarOps,
      "Location Graveyard": locGraveyardController.text,
      "DO Disability": doDisabilityController.text,
      "Nature Disability": natureDisabilityController.text,
      "CL Disability": clDisabilityController.text,
      "General Remarks": genRemarksController.text,
      "DASB": selectedDASB,
      "Source Verif...": selectedSourceVerification,
      "DO Verification": doVerificationController.text,
    };
    print('data------->$data');
    // showDialog(
    //   context: context,
    //   builder:
    //       (ctx) => AlertDialog(
    //         title: const Text("Collected Data"),
    //         content: SingleChildScrollView(
    //           child: Text(
    //             data.entries.map((e) => "${e.key}: ${e.value}").join("\n"),
    //           ),
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.of(ctx).pop(),
    //             child: const Text("OK"),
    //           ),
    //         ],
    //       ),
    // );
  }

  Widget _buildDropdown({
    required String hintText,
    required List<String> items,
    String? value,
    Color? borderColor,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? Color(0xffF3E7E2)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items
          .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Future<void> _loadRanks() async {
    final data = await AdminDB.instance.fetchAll('rank');
    setState(() {
      rankList = data;
    });
    print("✅ Rank data loaded: $rankList");
  }

  Future<void> _loadBanks() async {
    final data = await AdminDB.instance.fetchAll('lu_bank');
    setState(() {
      bankList = data;
    });
  }

  Future<void> loadPensionTypes() async {
    pensionTypes = await AdminDB.instance.fetchAll('Lu_Pension');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadRegtCorps();
    _loadRanks();
    _loadBanks();
    loadPensionTypes();
    if (widget.pensionData != null) {
      final data = widget.pensionData!;
      selectedPrefix = data["prefix"] ?? '';
      personalNoController.text = data["personal_no"] ?? '';
      tradeController.text = data["trade"] ?? '';
      nameController.text = data["name"] ?? '';
      parentUnitController.text = data["parent_unit"] ?? '';
      fatherNameController.text = data["father_name"] ?? '';
      dobController.text = data["dob"] ?? '';
      doEnltController.text = data["do_enlt"] ?? '';
      doDischController.text = data["do_disch"] ?? '';
      honoursController.text = data["honours"] ?? '';
      civilEdnController.text = data["civil_edn"] ?? '';
      causeDischController.text = data["cause_disch"] ?? '';
      villageController.text = data["village"] ?? '';
      postOfficeController.text = data["post_office"] ?? '';
      presentAddrController.text = data["present_addr"] ?? '';
      cnicController.text = data["cnic"] ?? '';
      mobileController.text = data["mobile"] ?? '';
      nokNameController.text = data["nok_name"] ?? '';
      nokCnicController.text = data["nok_cnic"] ?? '';
      doDeathController.text = data["do_death"] ?? '';
      placeDeathController.text = data["place_death"] ?? '';
      causeDeathController.text = data["cause_death"] ?? '';
      locGraveyardController.text = data["loc_graveyard"] ?? '';
      doDisabilityController.text = data["do_disability"] ?? '';
      natureDisabilityController.text = data["nature_disability"] ?? '';
      clDisabilityController.text = data["cl_disability"] ?? '';
      genRemarksController.text = data["gen_remarks"] ?? '';
      doVerificationController.text = data["do_verification"] ?? '';

      // Dropdown values
      selectedRankId = data["rank"];
      selectedRegtId = data["regt"];
      selectedMedCat = data["med_cat"];
      selectedCharacter = data["character"];
      selectedTypeOfPensionId = data["type_of_pension"];
      selectedNOKRelation = data["nok_relation"];
      selectedUCName = data["uc_name"];
      selectedTehsil = data["tehsil"];
      selectedDistrict = data["district"];
      selectedWarOps = data["war_ops"];
      selectedDASB = data["dasb"];
      selectedSourceVerification = data["source_verification"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Basic Data Entry Form'),
        backgroundColor: Color(0xff27ADF5),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxHeight = constraints.maxHeight;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: maxHeight),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Data
                      Expanded(
                        child: SectionColumn(
                          title: "Personal Data",
                          maxHeight: maxHeight,
                          children: [
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "Prefix *",
                                items: prefixOptions,
                                value: selectedPrefix,
                                onChanged: (val) {
                                  setState(() {
                                    selectedPrefix = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose prefix"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              borderColor: Colors.red,
                              hinttext: "Personal No *",
                              controller: personalNoController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "Required" : null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: DropdownButtonFormField<String>(
                                value:
                                    selectedForce, // <-- define this variable in your State
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Select Force *",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "Army",
                                    child: Text("Army"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PAF",
                                    child: Text("PAF"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Navy",
                                    child: Text("Navy"),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    selectedForce = val!;
                                  });
                                },
                                validator: (v) =>
                                    v == null ? "Please select force" : null,
                              ),
                            ),

                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: DropdownButtonFormField<int>(
                                value: selectedRankId,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Select Rank *",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                ),
                                items: rankList.map((rank) {
                                  return DropdownMenuItem<int>(
                                    value: rank['id'],
                                    child: Text(rank['rank'] ?? 'Unknown'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedRankId = val;
                                  });
                                },
                                validator: (v) =>
                                    v == null ? "Please select a rank" : null,
                              ),
                            ),

                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Trade",
                              controller: tradeController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              borderColor: Colors.red,
                              hinttext: "Name *",
                              controller: nameController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "Required" : null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: DropdownButtonFormField<int>(
                                value: selectedRegtId,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Regt/Corps *",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                ),
                                items: regtCorpsList.map<DropdownMenuItem<int>>(
                                  (regt) {
                                    return DropdownMenuItem<int>(
                                      value:
                                          regt['id']
                                              as int, // ensure it's an int
                                      child: Text(
                                        regt['regtcorps'] ??
                                            '', // wrap in Text widget
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    );
                                  },
                                ).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedRegtId =
                                        val; // update the selected ID
                                  });
                                },
                                validator: (v) =>
                                    (v == null) ? "Choose unit" : null,
                              ),
                            ),

                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Parent Unit",
                              controller: parentUnitController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Father Name",
                              controller: fatherNameController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            InlineDatePickerField(
                              hintText: "Date of Birth",
                              controller: dobController,
                              validator: (v) => null, // optional
                            ),

                            // Textfieldcomponent(
                            //   hinttext: "Date of Birth",
                            //   controller: dobController,
                            //   validator: (v) => null,
                            // ),
                            const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "DO Enlist",
                            //   controller: doEnltController,
                            //   validator: (v) => null,
                            // ),
                            InlineDatePickerField(
                              hintText: "DO Enlist",
                              controller: doEnltController,
                              validator: (v) => null, // optional
                            ),

                            const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "DO Discharge",
                            //   controller: doDischController,
                            //   validator: (v) => null,
                            // ),
                            InlineDatePickerField(
                              hintText: "DO Discharge",
                              controller: doDischController,
                              validator: (v) => null, // optional
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Honours / Awards",
                              controller: honoursController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Civil Education",
                              controller: civilEdnController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "Med Category *",
                                items: medCatOptions,
                                value: selectedMedCat,
                                onChanged: (val) {
                                  setState(() {
                                    selectedMedCat = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose med cat"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "Character *",
                                items: characterOptions,
                                value: selectedCharacter,
                                onChanged: (val) {
                                  setState(() {
                                    selectedCharacter = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose character"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Cause of Discharge",
                              controller: causeDischController,
                              validator: (v) => null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Address / Misc
                      Expanded(
                        child: SectionColumn(
                          title: "Home Address / Misc Data",
                          maxHeight: maxHeight,
                          children: [
                            Textfieldcomponent(
                              hinttext: "Village",
                              controller: villageController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Post Office",
                              controller: postOfficeController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "UC Name *",
                                items: ucNameOptions,
                                value: selectedUCName,
                                onChanged: (val) {
                                  setState(() {
                                    selectedUCName = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose UC"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "Tehsil *",
                                items: tehsilOptions,
                                value: selectedTehsil,
                                onChanged: (val) {
                                  setState(() {
                                    selectedTehsil = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose tehsil"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "District *",
                                items: districtOptions,
                                value: selectedDistrict,
                                onChanged: (val) {
                                  setState(() {
                                    selectedDistrict = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose district"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: TextFormField(
                                controller: presentAddrController,
                                keyboardType: TextInputType.multiline,
                                minLines: 1, // start with one line
                                maxLines: null, // expands automatically
                                validator: (value) {
                                  // if (value == null || value.isEmpty) {
                                  //   return 'Please enter present address';
                                  // }
                                  // return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Present Address",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.blueAccent,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "CNIC",
                              controller: cnicController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Mobile No",
                              controller: mobileController,
                              validator: (v) => null,
                              type: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "NOK Name",
                              controller: nokNameController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "NOK Relation *",
                                items: nokRelationOptions,
                                value: selectedNOKRelation,
                                onChanged: (val) {
                                  setState(() {
                                    selectedNOKRelation = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose NOK relation"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "NOK CNIC",
                              controller: nokCnicController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: DropdownButtonFormField<int>(
                                value: selectedTypeOfPensionId,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Type of Pension *",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                ),
                                items: pensionTypes.map((pension) {
                                  return DropdownMenuItem<int>(
                                    value: pension['id'], // primary key from DB
                                    child: Text(pension['Pension_Type'] ?? ''),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedTypeOfPensionId = val; // store ID
                                    // store name for display or later use
                                    selectedTypeOfPensionName = pensionTypes
                                        .firstWhere(
                                          (p) => p['id'] == val,
                                        )['Pension_Type'];
                                  });
                                },
                                validator: (v) =>
                                    (v == null) ? "Choose pension type" : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Shuhada / Disabled
                      Expanded(
                        child: SectionColumn(
                          title: "Shuhada / Disabled Data",
                          maxHeight: maxHeight,
                          children: [
                            InlineDatePickerField(
                              hintText: "DO Death / Shahadat",
                              controller: doDeathController,
                              validator: (v) => null, // optional
                            ),

                            // Textfieldcomponent(
                            //   hinttext: "DO Death / Shahadat",
                            //   controller: doDeathController,
                            //   validator: (v) =>
                            //       null, // or make required if needed
                            // ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Place Death / Shahadat",
                              controller: placeDeathController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Cause Death / Shahadat",
                              controller: causeDeathController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "War / Ops *",
                                items: warOpsOptions,
                                value: selectedWarOps,
                                onChanged: (val) {
                                  setState(() {
                                    selectedWarOps = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose war/ops"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Location of Graveyard",
                              controller: locGraveyardController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "DO Disability",
                            //   controller: doDisabilityController,
                            //   validator: (v) => null,
                            // ),
                            InlineDatePickerField(
                              hintText: "DO Disability",
                              controller: doDisabilityController,
                              validator: (v) => null, // optional
                            ),

                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Nature of Disability",
                              controller: natureDisabilityController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "CL Disability",
                              controller: clDisabilityController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "General Remarks",
                              controller: genRemarksController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "DASB *",
                                items: dasbOptions,
                                value: selectedDASB,
                                onChanged: (val) {
                                  setState(() {
                                    selectedDASB = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose DASB"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: _buildDropdown(
                                borderColor: Colors.red,
                                hintText: "Source Verifi... *",
                                items: sourceVerificationOptions,
                                value: selectedSourceVerification,
                                onChanged: (val) {
                                  setState(() {
                                    selectedSourceVerification = val;
                                  });
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Choose source"
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InlineDatePickerField(
                              hintText: "DO Verification",
                              controller: doVerificationController,
                              validator: (v) => null, // optional
                            ),

                            // Textfieldcomponent(
                            //   hinttext: "DO Verification",
                            //   controller: doVerificationController,
                            //   validator: (v) => null,
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SectionColumn(
                          title: 'Bank & Pension Details',
                          maxHeight: maxHeight,
                          children: [
                            // Textfieldcomponent(
                            //   hinttext: "GPO",
                            //   controller: gpoController,
                            //   validator: (v) => null,
                            // ),
                            // const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "PDO",
                            //   controller: pdoController,
                            //   validator: (v) => null,
                            // ),
                            // const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "PSB No",
                            //   controller: psbNoController,
                            //   validator: (v) => null,
                            // ),
                            //  const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "PPO No",
                              controller: ppoNoController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 340,
                              child: DropdownButtonFormField<int>(
                                value: selectedBankId,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Select Bank *",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                ),
                                items: bankList.map((bank) {
                                  return DropdownMenuItem<int>(
                                    value:
                                        bank['id'], // store the bank's primary key
                                    child: Text(bank['name']),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedBankId = val;
                                  });
                                },
                                validator: (v) =>
                                    v == null ? "Please select a bank" : null,
                              ),
                            ),

                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Bank Branch",
                              controller: bankBranchController,
                              validator: (v) => null,
                            ),
                            // const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "Bank Account No",
                            //   controller: bankAcctNoController,
                            //   validator: (v) => null,
                            // ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "IBAN No",
                              controller: ibanNoController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Net Pension",
                              controller: netPensionController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Register Page",
                              controller: registerPageController,
                              validator: (v) => null,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SectionColumn(
                          title: 'NOK Details',
                          maxHeight: maxHeight,
                          children: [
                            // Textfieldcomponent(
                            //   hinttext: "Date of Birth",
                            //   controller: nokDoBirthController,
                            //   validator: (v) => null,
                            //   onTap: () => setState(() => showCalendar = !showCalendar),
                            // ),

                            // Textfieldcomponent(
                            //   hinttext: "Date of Birth",
                            //   controller: nokDoBirthController,
                            //   validator: (v) => null,
                            // ),
                            //  const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "ID Marks",
                            //   controller: nokIdMksController,
                            //   validator: (v) => null,
                            // ),
                            // const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "GPO",
                            //   controller: nokGpoController,
                            //   validator: (v) => null,
                            // ),
                            // const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "PDO",
                            //   controller: nokPdoController,
                            //   validator: (v) => null,
                            // ),
                            // const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "PSB No",
                            //   controller: nokPsbNoController,
                            //   validator: (v) => null,
                            // ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "PPO No",
                              controller: nokPpoNoController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Bank Name",
                              controller: nokBankNameController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Bank Branch",
                              controller: nokBankBranchController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            // Textfieldcomponent(
                            //   hinttext: "Bank Account No",
                            //   controller: nokBankAcctNoController,
                            //   validator: (v) => null,
                            // ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "IBAN No",
                              controller: nokIbanNoController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Net Pension",
                              controller: nokNetPensionController,
                              validator: (v) => null,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SectionColumn(
                          title: 'Shuhada / Disabled & Verification Details',
                          maxHeight: maxHeight,
                          children: [
                            Textfieldcomponent(
                              hinttext: "Cause of Disability",
                              controller: causeDisabilityController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Citation Shaheed",
                              controller: citationShaheedController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Tomb Stone",
                              controller: tombStoneController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Shaheed Remarks",
                              controller: shaheedRemarksController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Disable Remarks",
                              controller: disableRemarksController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Date Verification",
                              controller: dateVerificationController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Source Verification",
                              controller: sourceVerificationController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "DCS Start Month",
                              controller: dcsStartMonthController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Last Modified By",
                              controller: lastModifiedByController,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 8),
                            Textfieldcomponent(
                              hinttext: "Last Modified Date",
                              controller: lastModifiedDateController,
                              validator: (v) => null,
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(width: 12),
                      // SectionColumn(
                      //   title: 'Additional Personal / Misc Details',
                      //   maxHeight: maxHeight,
                      //   children: [
                      //     Textfieldcomponent(
                      //       hinttext: "CMP CNIC No",
                      //       controller: cmpCnicController,
                      //       validator: (v) => null,
                      //     ),
                      //     const SizedBox(height: 8),
                      //     Textfieldcomponent(
                      //       hinttext: "Identification Marks",
                      //       controller: idMarksController,
                      //       validator: (v) => null,
                      //     ),
                      //     const SizedBox(height: 8),
                      //     Textfieldcomponent(
                      //       hinttext: "Railway Station",
                      //       controller: railwayStationController,
                      //       validator: (v) => null,
                      //     ),
                      //     const SizedBox(height: 8),
                      //     Textfieldcomponent(
                      //       hinttext: "Police Station",
                      //       controller: policeStationController,
                      //       validator: (v) => null,
                      //     ),
                      //     const SizedBox(height: 8),
                      //     Textfieldcomponent(
                      //       hinttext: "Military Qualification",
                      //       controller: milQualController,
                      //       validator: (v) => null,
                      //     ),
                      //   ],
                      // ),
                      // Optionally, you can place Save/Submit button here or at bottom
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _onSave,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _clearForm,
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep SectionColumn unchanged (same as before)
class SectionColumn extends StatelessWidget {
  final String title;
  final double maxHeight;
  final List<Widget> children;

  const SectionColumn({
    super.key,
    required this.title,
    required this.maxHeight,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(),
          SizedBox(
            height: maxHeight - 100,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
