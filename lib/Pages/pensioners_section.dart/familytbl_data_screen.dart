import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:testing_window_app/components/date_picker.dart';
import 'package:testing_window_app/components/textfield_component.dart';
import 'package:testing_window_app/sqlite/familTbl_database_helper.dart';
import 'package:testing_window_app/sqlite/lupension_database_Helper.dart';

import 'package:testing_window_app/sqlite/user_database_helper.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart'; // for fetching from BasicTbl

class FamilytblDataScreen extends StatefulWidget {
  final Map<String, dynamic>? nokData;
  const FamilytblDataScreen({super.key, this.nokData});

  @override
  State<FamilytblDataScreen> createState() => _NokDataScreenState();
}

class _NokDataScreenState extends State<FamilytblDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // ✅ Controllers for all NOK fields
  final TextEditingController _persNoController = TextEditingController();
  final TextEditingController _nokNameController = TextEditingController();
  final TextEditingController _nokRelationController = TextEditingController();
  final TextEditingController _nokDoBirthController = TextEditingController();
  final TextEditingController _nokDoDeathController = TextEditingController();
  final TextEditingController _nokDoMarriageController =
      TextEditingController();
  final TextEditingController _nokEdnController = TextEditingController();
  final TextEditingController _nokProfessionController =
      TextEditingController();
  final TextEditingController _nokMaritalStatusController =
      TextEditingController();
  final TextEditingController _nokDisabilityController =
      TextEditingController();
  final TextEditingController _nokCnicController = TextEditingController();
  final TextEditingController _nokIdMksController = TextEditingController();
  final TextEditingController _nokMobileController = TextEditingController();
  final TextEditingController _nokSourceOfIncomeController =
      TextEditingController();
  final TextEditingController _nokMonthlyIncomeController =
      TextEditingController();
  final TextEditingController _nokDoDivorcedController =
      TextEditingController();
  final TextEditingController _amountChildrenAllceController =
      TextEditingController();
  final TextEditingController _doChildrenAllceController =
      TextEditingController();
  final TextEditingController _nokRemarksController = TextEditingController();
  final TextEditingController _nokPsbNoController = TextEditingController();
  final TextEditingController _nokPpoNoController = TextEditingController();
  final TextEditingController _nokGpoController = TextEditingController();
  final TextEditingController _nokPdoController = TextEditingController();
  final TextEditingController _nokNetPensionController =
      TextEditingController();
  final TextEditingController _nokBankNameController = TextEditingController();
  final TextEditingController _nokBankBranchController =
      TextEditingController();
  final TextEditingController _nokBankCodeController = TextEditingController();
  final TextEditingController _nokBankAcctNoController =
      TextEditingController();
  final TextEditingController _nokIbanNoController = TextEditingController();
  final TextEditingController _dcsStartMonthController =
      TextEditingController();
  final TextEditingController _nokTypeOfPensionController =
      TextEditingController();

  // Future<void> _loadPensionTypes() async {
  //   final pensions = await LuPensionDatabase.instance.getAllPensions();
  //   if (!mounted) return;

  //   setState(() {
  //     _pensionTypes = pensions.map((e) => e['Pension_Type'] as String).toList();
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // _loadPensionTypes(); // fetch types from LuPension
    if (widget.nokData != null) {
      _persNoController.text = widget.nokData!['PersNo'] ?? '';
      _nokNameController.text = widget.nokData!['NOKName'] ?? '';
      _nokRelationController.text = widget.nokData!['NOKRelation'] ?? '';
      _nokDoBirthController.text = widget.nokData!['NOKDOB'] ?? '';
      _nokDoDeathController.text = widget.nokData!['NOKDOD'] ?? '';
      _nokDoMarriageController.text = widget.nokData!['NOKDOM'] ?? '';
      _nokEdnController.text = widget.nokData!['NOKEdn'] ?? '';
      _nokProfessionController.text = widget.nokData!['NOKProfession'] ?? '';
      _nokMaritalStatusController.text =
          widget.nokData!['NOKMaritialStatus'] ?? '';
      _nokDisabilityController.text = widget.nokData!['NOKDisability'] ?? '';
      _nokCnicController.text = widget.nokData!['NOKCNIC'] ?? '';
      _nokIdMksController.text = widget.nokData!['NOKIDMks'] ?? '';
      _nokMobileController.text = widget.nokData!['NOKMobileNo'] ?? '';
      _nokSourceOfIncomeController.text =
          widget.nokData!['NOKSourceOfIncome'] ?? '';
      _nokMonthlyIncomeController.text =
          widget.nokData!['NOKMonthlyIncome']?.toString() ?? '';
      _nokDoDivorcedController.text = widget.nokData!['NOKDODivorced'] ?? '';
      _amountChildrenAllceController.text =
          widget.nokData!['AmountChildrenAllce']?.toString() ?? '';
      _doChildrenAllceController.text =
          widget.nokData!['DOChildrenAllce'] ?? '';
      _nokRemarksController.text = widget.nokData!['NOKRemarks'] ?? '';
      _nokPsbNoController.text = widget.nokData!['NOKPSBNo'] ?? '';
      _nokPpoNoController.text = widget.nokData!['NOKPPONo'] ?? '';
      _nokGpoController.text = widget.nokData!['NOKGPO'] ?? '';
      _nokPdoController.text = widget.nokData!['NOKPDO'] ?? '';
      _nokNetPensionController.text =
          widget.nokData!['NOKNetPension']?.toString() ?? '';
      _nokBankNameController.text = widget.nokData!['NOKBankName'] ?? '';
      _nokBankBranchController.text = widget.nokData!['NOKBankBranch'] ?? '';
      _nokBankCodeController.text = widget.nokData!['NOKBankCode'] ?? '';
      _nokBankAcctNoController.text = widget.nokData!['NOKBankAcctNo'] ?? '';
      _nokIbanNoController.text = widget.nokData!['NOKIBANNo'] ?? '';
      _dcsStartMonthController.text = widget.nokData!['DCSStartMonth'] ?? '';
      _selectedPensionType = widget.nokData!['NOKTypeOfPension'];
    }
  }

  @override
  void dispose() {
    _persNoController.dispose();
    _nokNameController.dispose();
    _nokRelationController.dispose();
    _nokDoBirthController.dispose();
    _nokDoDeathController.dispose();
    _nokDoMarriageController.dispose();
    _nokEdnController.dispose();
    _nokProfessionController.dispose();
    _nokMaritalStatusController.dispose();
    _nokDisabilityController.dispose();
    _nokCnicController.dispose();
    _nokIdMksController.dispose();
    _nokMobileController.dispose();
    _nokSourceOfIncomeController.dispose();
    _nokMonthlyIncomeController.dispose();
    _nokDoDivorcedController.dispose();
    _amountChildrenAllceController.dispose();
    _doChildrenAllceController.dispose();
    _nokRemarksController.dispose();
    _nokPsbNoController.dispose();
    _nokPpoNoController.dispose();
    _nokGpoController.dispose();
    _nokPdoController.dispose();
    _nokNetPensionController.dispose();
    _nokBankNameController.dispose();
    _nokBankBranchController.dispose();
    _nokBankCodeController.dispose();
    _nokBankAcctNoController.dispose();
    _nokIbanNoController.dispose();
    _dcsStartMonthController.dispose();
    _nokTypeOfPensionController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _persNoController.clear();
    _nokNameController.clear();
    _nokRelationController.clear();
    _nokDoBirthController.clear();
    _nokDoDeathController.clear();
    _nokDoMarriageController.clear();
    _nokEdnController.clear();
    _nokProfessionController.clear();
    _nokMaritalStatusController.clear();
    _nokDisabilityController.clear();
    _nokCnicController.clear();
    _nokIdMksController.clear();
    _nokMobileController.clear();
    _nokSourceOfIncomeController.clear();
    _nokMonthlyIncomeController.clear();
    _nokDoDivorcedController.clear();
    _amountChildrenAllceController.clear();
    _doChildrenAllceController.clear();
    _nokRemarksController.clear();
    _nokPsbNoController.clear();
    _nokPpoNoController.clear();
    _nokGpoController.clear();
    _nokPdoController.clear();
    _nokNetPensionController.clear();
    _nokBankNameController.clear();
    _nokBankBranchController.clear();
    _nokBankCodeController.clear();
    _nokBankAcctNoController.clear();
    _nokIbanNoController.clear();
    _dcsStartMonthController.clear();
    _nokTypeOfPensionController.clear();

    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Form cleared")));
  }

  String? _selectedPensionType;
  List<String> _pensionTypes = [];

  // Future<void> _fetchFromBasicTbl(String personalNo) async {
  //   if (personalNo.isEmpty) return;

  //   // 1️⃣ Fetch from BasicTbl
  //   final record = await AdminDB.instance.getRecordByPersonalNo(personalNo);

  //   // 2️⃣ Fetch type of pension from LuPension
  //  // final pensions = await AdminDB.instance.getAllPensions();
  //   // Optional: pick based on personalNo or just take the first for demo
  //   String pensionTypeFromLu = pensions.isNotEmpty
  //       ? pensions.first['Pension_Type']
  //       : '';

  //   if (!mounted) return;

  //   if (record != null) {
  //     setState(() {
  //       _nokNameController.text = record['nok_name'] ?? '';
  //       _nokRelationController.text = record['nok_relation'] ?? '';
  //       _nokCnicController.text = record['nok_cnic'] ?? '';
  //       _nokDoBirthController.text = record['nok_do_birth'] ?? '';
  //       _nokIdMksController.text = record['nok_id_mks'] ?? '';
  //       _nokPsbNoController.text = record['nok_psb_no'] ?? '';
  //       _nokPpoNoController.text = record['nok_ppo_no'] ?? '';
  //       _nokGpoController.text = record['nok_gpo'] ?? '';
  //       _nokPdoController.text = record['nok_pdo'] ?? '';
  //       _nokBankNameController.text = record['nok_bank_name'] ?? '';
  //       _nokBankBranchController.text = record['nok_bank_branch'] ?? '';
  //       _nokBankAcctNoController.text = record['nok_bank_acct_no'] ?? '';
  //       _nokIbanNoController.text = record['nok_iban_no'] ?? '';
  //       _nokNetPensionController.text =
  //           record['nok_net_pension']?.toString() ?? '';
  //       _nokDoDeathController.text = record['do_death'] ?? '';
  //       // ✅ Instead of BasicTbl, set from LuPension
  //       _nokTypeOfPensionController.text = pensionTypeFromLu;
  //       _selectedPensionType = pensionTypeFromLu; // If using Dropdown
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("No record found in BasicTbl")),
  //     );
  //   }
  // }

  Future<void> _saveDataToDb() async {
    if (!_formKey.currentState!.validate()) return;

    final nokData = {
      'PersNo': _persNoController.text.trim(),
      'NOKName': _nokNameController.text.trim(),
      'NOKRelation': _nokRelationController.text.trim(),
      'NOKDOB': _nokDoBirthController.text.trim(),
      'NOKDOD': _nokDoDeathController.text.trim(),
      'NOKDOM': _nokDoMarriageController.text.trim(),
      'NOKEdn': _nokEdnController.text.trim(),
      'NOKProfession': _nokProfessionController.text.trim(),
      'NOKMaritialStatus': _nokMaritalStatusController.text.trim(),
      'NOKDisability': _nokDisabilityController.text.trim(),
      'NOKCNIC': _nokCnicController.text.trim(),
      'NOKIDMks': _nokIdMksController.text.trim(),
      'NOKMobileNo': _nokMobileController.text.trim(),
      'NOKSourceOfIncome': _nokSourceOfIncomeController.text.trim(),
      'NOKMonthlyIncome':
          int.tryParse(_nokMonthlyIncomeController.text.trim()) ?? 0,
      'NOKDODivorced': _nokDoDivorcedController.text.trim(),
      'AmountChildrenAllce':
          int.tryParse(_amountChildrenAllceController.text.trim()) ?? 0,
      'DOChildrenAllce': _doChildrenAllceController.text.trim(),
      'NOKRemarks': _nokRemarksController.text.trim(),
      'NOKPSBNo': _nokPsbNoController.text.trim(),
      'NOKPPONo': _nokPpoNoController.text.trim(),
      'NOKGPO': _nokGpoController.text.trim(),
      'NOKPDO': _nokPdoController.text.trim(),
      'NOKNetPension': int.tryParse(_nokNetPensionController.text.trim()) ?? 0,
      'NOKBankName': _nokBankNameController.text.trim(),
      'NOKBankBranch': _nokBankBranchController.text.trim(),
      'NOKBankCode': _nokBankCodeController.text.trim(),
      'NOKBankAcctNo': _nokBankAcctNoController.text.trim(),
      'NOKIBANNo': _nokIbanNoController.text.trim(),
      'DCSStartMonth': _dcsStartMonthController.text.trim(),
      'NOKTypeOfPension': _nokTypeOfPensionController.text.trim(),
    };

    try {
      if (widget.nokData == null) {
        await FamilyDB.instance.insertNOK(nokData);
        print('NOK record added successfully');
      } else {
        await FamilyDB.instance.updateNOK(widget.nokData!['NOKID'], nokData);
        print('NOK record updated successfully');
      }
    } catch (e) {
      print('Error saving NOK record: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving NOK record: $e')));
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    void Function(String)? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Textfieldcomponent(
        hinttext: label,
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? "Required field" : null,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.nokData == null ? "Add Family Data" : "Edit Family Data",
        ),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  // _buildTextField(
                  //   "PersNo",
                  //   _persNoController,
                  //   onSubmitted: (value) => _fetchFromBasicTbl(value),
                  // ),
                  _buildTextField("NOK Name", _nokNameController),
                  _buildTextField("NOK Relation", _nokRelationController),
                  SizedBox(
                    width: 350,
                    child: InlineDatePickerField(
                      hintText: "NOK DOB",
                      controller: _nokDoBirthController,
                      validator: (v) => null, // optional
                    ),
                  ),

                  //  _buildTextField("NOK DOB", _nokDoBirthController),
                  SizedBox(
                    width: 350,
                    child: InlineDatePickerField(
                      hintText: "NOK DO Death",
                      controller: _nokDoDeathController,
                      validator: (v) => null, // optional
                    ),
                  ),
                  // _buildTextField("NOK DO Death", _nokDoDeathController),
                  SizedBox(
                    width: 350,
                    child: InlineDatePickerField(
                      hintText: "NOK DO Marriage",
                      controller: _nokDoMarriageController,
                      validator: (v) => null, // optional
                    ),
                  ),
                  //  _buildTextField("NOK DO Marriage", _nokDoMarriageController),
                  _buildTextField("NOK Edn", _nokEdnController),
                  _buildTextField("NOK Profession", _nokProfessionController),
                  _buildTextField(
                    "NOK Marital Status",
                    _nokMaritalStatusController,
                  ),
                  _buildTextField("NOK Disability", _nokDisabilityController),
                  _buildTextField("NOK CNIC", _nokCnicController),
                  _buildTextField("NOK ID Mks", _nokIdMksController),
                  _buildTextField("NOK Mobile No", _nokMobileController),
                  _buildTextField(
                    "NOK Source of Income",
                    _nokSourceOfIncomeController,
                  ),
                  _buildTextField(
                    "NOK Monthly Income",
                    _nokMonthlyIncomeController,
                  ),
                  SizedBox(
                    width: 350,
                    child: InlineDatePickerField(
                      hintText: "NOK DO Divorced",
                      controller: _nokDoDivorcedController,
                      validator: (v) => null, // optional
                    ),
                  ),
                  //  _buildTextField("NOK DO Divorced", _nokDoDivorcedController),
                  _buildTextField(
                    "Amount Children Allce",
                    _amountChildrenAllceController,
                  ),
                  // _buildTextField(
                  //   "DO Children Allce",
                  //   _doChildrenAllceController,
                  // ),
                  SizedBox(
                    width: 350,
                    child: InlineDatePickerField(
                      hintText: "DO Children Allce",
                      controller: _doChildrenAllceController,
                      validator: (v) => null, // optional
                    ),
                  ),
                  _buildTextField("NOK Remarks", _nokRemarksController),
                  _buildTextField("NOK PSB No", _nokPsbNoController),
                  _buildTextField("NOK PPO No", _nokPpoNoController),
                  _buildTextField("NOK GPO", _nokGpoController),
                  _buildTextField("NOK PDO", _nokPdoController),
                  _buildTextField("NOK Net Pension", _nokNetPensionController),
                  _buildTextField("NOK Bank Name", _nokBankNameController),
                  _buildTextField("NOK Bank Branch", _nokBankBranchController),
                  _buildTextField("NOK Bank Code", _nokBankCodeController),
                  _buildTextField("NOK Bank Acct No", _nokBankAcctNoController),
                  _buildTextField("NOK IBAN No", _nokIbanNoController),
                  _buildTextField("DCS Start Month", _dcsStartMonthController),
                  SizedBox(
                    width: 345,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPensionType,
                      decoration: InputDecoration(
                        hintText: "NOK Type of Pension",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _pensionTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPensionType = value;
                          _nokTypeOfPensionController.text = value ?? '';
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? "Required field"
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveDataToDb,
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
                    child: Text(
                      widget.nokData == null ? "Save" : "Update Data",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _clearForm,
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
                    child: const Text(
                      "Reset",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
