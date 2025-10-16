import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:testing_window_app/components/textfield_component.dart';

import 'package:testing_window_app/sqlite/benTbl_database_helper.dart';
import 'package:testing_window_app/sqlite/user_database_helper.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class BenDataScreen extends StatefulWidget {
  final Map<String, dynamic>? benData;
  const BenDataScreen({super.key, this.benData});

  @override
  State<BenDataScreen> createState() => _BenDataScreenState();
}

class _BenDataScreenState extends State<BenDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // ✅ Controllers for all fields
  final TextEditingController _benPersNoController = TextEditingController();
  final TextEditingController _benBankerNameController =
      TextEditingController();
  final TextEditingController _benBranchCodeController =
      TextEditingController();
  final TextEditingController _benBankAcctNoController =
      TextEditingController();
  final TextEditingController _benBankIBANNoController =
      TextEditingController();
  final TextEditingController _benRemarksController = TextEditingController();
  final TextEditingController _amountReceivedController =
      TextEditingController();
  final TextEditingController _amountReceivedDateController =
      TextEditingController();
  final TextEditingController _maritalStatusController =
      TextEditingController();
  final TextEditingController _dasbFileNoController = TextEditingController();
  final TextEditingController _benOriginatorController =
      TextEditingController();
  final TextEditingController _benOriginatorLtrDateController =
      TextEditingController();
  final TextEditingController _benOriginatorLtrNoController =
      TextEditingController();
  final TextEditingController _caseReceivedController = TextEditingController();
  final TextEditingController _benStatusController = TextEditingController();
  final TextEditingController _hwoConcernedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.benData != null) {
      _benPersNoController.text = widget.benData!['BenPersNo'] ?? '';
      _benBankerNameController.text = widget.benData!['BenBankerName'] ?? '';
      _benBranchCodeController.text = widget.benData!['BenBranchCode'] ?? '';
      _benBankAcctNoController.text = widget.benData!['BenBankAcctNo'] ?? '';
      _benBankIBANNoController.text = widget.benData!['BenBankIBANNo'] ?? '';
      _benRemarksController.text = widget.benData!['BenRemarks'] ?? '';
      _amountReceivedController.text = widget.benData!['AmountReceived'] ?? '';
      _amountReceivedDateController.text =
          widget.benData!['AmountReceivedDate'] ?? '';
      _maritalStatusController.text = widget.benData!['MaritalStatus'] ?? '';
      _dasbFileNoController.text = widget.benData!['DASBFileNo'] ?? '';
      _benOriginatorController.text = widget.benData!['BenOriginator'] ?? '';
      _benOriginatorLtrDateController.text =
          widget.benData!['BenOriginatorLtrDate'] ?? '';
      _benOriginatorLtrNoController.text =
          widget.benData!['BenOriginatorLtrNo'] ?? '';
      _caseReceivedController.text =
          widget.benData!['CaseReceivedForVerification'] ?? '';
      _benStatusController.text = widget.benData!['BenStatus'] ?? '';
      _hwoConcernedController.text = widget.benData!['HWOConcerned'] ?? '';
    }
  }

  @override
  void dispose() {
    _benPersNoController.dispose();
    _benBankerNameController.dispose();
    _benBranchCodeController.dispose();
    _benBankAcctNoController.dispose();
    _benBankIBANNoController.dispose();
    _benRemarksController.dispose();
    _amountReceivedController.dispose();
    _amountReceivedDateController.dispose();
    _maritalStatusController.dispose();
    _dasbFileNoController.dispose();
    _benOriginatorController.dispose();
    _benOriginatorLtrDateController.dispose();
    _benOriginatorLtrNoController.dispose();
    _caseReceivedController.dispose();
    _benStatusController.dispose();
    _hwoConcernedController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _benPersNoController.clear();
    _benBankerNameController.clear();
    _benBranchCodeController.clear();
    _benBankAcctNoController.clear();
    _benBankIBANNoController.clear();
    _benRemarksController.clear();
    _amountReceivedController.clear();
    _amountReceivedDateController.clear();
    _maritalStatusController.clear();
    _dasbFileNoController.clear();
    _benOriginatorController.clear();
    _benOriginatorLtrDateController.clear();
    _benOriginatorLtrNoController.clear();
    _caseReceivedController.clear();
    _benStatusController.clear();
    _hwoConcernedController.clear();

    setState(() {}); // refresh UI if needed

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Form cleared")));
  }

  Future<void> _fetchFromBasicTbl(String personalNo) async {
    if (personalNo.isEmpty) return;

    print('Fetching record for Personal No: $personalNo');
    final record = await AdminDB.instance.getRecordByPersonalNo(personalNo);

    print('Record result: $record');

    if (!mounted) return; // ✅ Prevent setState after widget disposal

    if (record != null) {
      setState(() {
        _benBankerNameController.text = record['bank_name'] ?? '';
        _benBranchCodeController.text = record['bank_branch'] ?? '';
        _benBankAcctNoController.text = record['bank_acct_no'] ?? '';
        _benBankIBANNoController.text = record['iban_no'] ?? '';
        _benRemarksController.text = record['gen_remarks'] ?? '';
      });
      print('Fields updated from BasicTbl ✅');
    } else {
      print('⚠️ No record found in BasicTbl');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No record found in BasicTbl")),
      );
    }
  }

  Future<void> _saveDataToDb() async {
    if (!_formKey.currentState!.validate()) return;

    final benData = {
      'BenPersNo': _benPersNoController.text.trim(),
      'BenBankerName': _benBankerNameController.text.trim(),
      'BenBranchCode': _benBranchCodeController.text.trim(),
      'BenBankAcctNo': _benBankAcctNoController.text.trim(),
      'BenBankIBANNo': _benBankIBANNoController.text.trim(),
      'BenRemarks': _benRemarksController.text.trim(),
      'AmountReceived': _amountReceivedController.text.trim(),
      'AmountReceivedDate': _amountReceivedDateController.text.trim(),
      'MaritalStatus': _maritalStatusController.text.trim(),
      'DASBFileNo': _dasbFileNoController.text.trim(),
      'BenOriginator': _benOriginatorController.text.trim(),
      'BenOriginatorLtrDate': _benOriginatorLtrDateController.text.trim(),
      'BenOriginatorLtrNo': _benOriginatorLtrNoController.text.trim(),
      'CaseReceivedForVerification': _caseReceivedController.text.trim(),
      'BenStatus': _benStatusController.text.trim(),
      'HWOConcerned': _hwoConcernedController.text.trim(),
    };

    try {
      if (widget.benData == null) {
        await BenDB.instance.insertBen(benData);
        print('Record added successfully');
      } else {
        await BenDB.instance.updateBen(widget.benData!['BenID'], benData);
        print('Record updated successfully');
      }
      if (!mounted) return;
      //  Navigator.pop(context, true);
    } catch (e, st) {
      print('Error saving record: $e');
      print(st);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving record: $e')));
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
        onSubmitted: onSubmitted, // 👈 optional callback
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff27ADF5),
        title: Text(
          widget.benData == null
              ? "Add Beneficiary Data"
              : "Edit Beneficiary Data",
        ),
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
                  _buildTextField(
                    "BenPersNo",
                    _benPersNoController,
                    onSubmitted: (value) => _fetchFromBasicTbl(value),
                  ),
                  _buildTextField("BenBankerName", _benBankerNameController),
                  _buildTextField("BenBranchCode", _benBranchCodeController),
                  _buildTextField("BenBankAcctNo", _benBankAcctNoController),
                  _buildTextField("BenBankIBANNo", _benBankIBANNoController),
                  _buildTextField("BenRemarks", _benRemarksController),
                  _buildTextField("AmountReceived", _amountReceivedController),
                  _buildTextField(
                    "AmountReceivedDate",
                    _amountReceivedDateController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width:
                          340, // 👈 Adjust to match your text fields’ typical width
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: "Marital Status",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        value: _maritalStatusController.text.isNotEmpty
                            ? _maritalStatusController.text
                            : null,
                        items: const [
                          DropdownMenuItem(value: "Yes", child: Text("Yes")),
                          DropdownMenuItem(value: "No", child: Text("No")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _maritalStatusController.text = value ?? '';
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Required field"
                            : null,
                      ),
                    ),
                  ),

                  _buildTextField("DASB File No", _dasbFileNoController),
                  _buildTextField("BenOriginator", _benOriginatorController),
                  _buildTextField(
                    "BenOriginatorLtrDate",
                    _benOriginatorLtrDateController,
                  ),
                  _buildTextField(
                    "BenOriginatorLtrNo",
                    _benOriginatorLtrNoController,
                  ),
                  _buildTextField(
                    "CaseReceivedForVerification",
                    _caseReceivedController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 340, // Match width with other fields
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: "BenStatus",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        value: _benStatusController.text.isNotEmpty
                            ? _benStatusController.text
                            : null,
                        items: const [
                          DropdownMenuItem(
                            value: "Received",
                            child: Text("Received"),
                          ),
                          DropdownMenuItem(
                            value: "Forward",
                            child: Text("Forward"),
                          ),
                          DropdownMenuItem(
                            value: "Accepted",
                            child: Text("Accepted"),
                          ),
                          DropdownMenuItem(
                            value: "Verified",
                            child: Text("Verified"),
                          ),
                          DropdownMenuItem(
                            value: "Rejected",
                            child: Text("Rejected"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _benStatusController.text = value ?? '';
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Required field"
                            : null,
                      ),
                    ),
                  ),

                  _buildTextField("HWOConcerned", _hwoConcernedController),
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
                      widget.benData == null ? "Save" : "Update Data",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
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
                    child: Text("Reset", style: TextStyle(color: Colors.white)),
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
