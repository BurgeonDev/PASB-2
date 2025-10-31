import 'package:flutter/material.dart';
import 'package:testing_window_app/components/textfield_component.dart';

import 'package:testing_window_app/sqlite/hwtbl_database_helper.dart';
import 'package:testing_window_app/sqlite/user_database_helper.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class HWDataScreen extends StatefulWidget {
  final Map<String, dynamic>? hwData;
  const HWDataScreen({super.key, this.hwData});

  @override
  State<HWDataScreen> createState() => _HWDataScreenState();
}

class _HWDataScreenState extends State<HWDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _hwPersNoController = TextEditingController();
  final TextEditingController _doApptController = TextEditingController();
  final TextEditingController _extnUptoController = TextEditingController();
  final TextEditingController _doRelqController = TextEditingController();
  final TextEditingController _causeOfRelqController = TextEditingController();
  final TextEditingController _aorController = TextEditingController();
  final TextEditingController _checkedController = TextEditingController();
  final TextEditingController _pageNoController = TextEditingController();
  final TextEditingController _hwRemarksController = TextEditingController();
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.hwData != null) {
      _hwPersNoController.text = widget.hwData!['HWPersNo']?.toString() ?? '';
      _doApptController.text = widget.hwData!['DOAppt'] ?? '';
      _extnUptoController.text = widget.hwData!['ExtnUpto'] ?? '';
      _doRelqController.text = widget.hwData!['DORelq'] ?? '';
      _causeOfRelqController.text = widget.hwData!['CauseOfRelq'] ?? '';
      _aorController.text = widget.hwData!['AOR'] ?? '';
      _checkedController.text = widget.hwData!['Checked'] ?? '';
      _pageNoController.text = widget.hwData!['PageNo'] ?? '';
      _hwRemarksController.text = widget.hwData!['HWRemarks'] ?? '';
      _picController.text = widget.hwData!['Pic'] ?? '';
      _accountNoController.text = widget.hwData!['AccountNo']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _hwPersNoController.dispose();
    _doApptController.dispose();
    _extnUptoController.dispose();
    _doRelqController.dispose();
    _causeOfRelqController.dispose();
    _aorController.dispose();
    _checkedController.dispose();
    _pageNoController.dispose();
    _hwRemarksController.dispose();
    _picController.dispose();
    _accountNoController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _hwPersNoController.clear();
    _doApptController.clear();
    _extnUptoController.clear();
    _doRelqController.clear();
    _causeOfRelqController.clear();
    _aorController.clear();
    _checkedController.clear();
    _pageNoController.clear();
    _hwRemarksController.clear();
    _picController.clear();
    _accountNoController.clear();
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Form cleared")));
  }

  Future<void> _fetchFromBasicTbl(String personalNo) async {
    if (personalNo.isEmpty) return;

    final record = await AdminDB.instance.getRecordByPersonalNo(personalNo);

    if (!mounted) return;

    if (record != null) {
      setState(() {
        //   _aorController.text = record['bank_name'] ?? '';
        _accountNoController.text = record['bank_acct_no']?.toString() ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No record found in BasicTbl")),
      );
    }
  }

  Future<void> _saveDataToDb() async {
    if (!_formKey.currentState!.validate()) return;

    final hwData = {
      'HWPersNo': _hwPersNoController.text.trim(),
      'DOAppt': _doApptController.text.trim(),
      'ExtnUpto': _extnUptoController.text.trim(),
      'DORelq': _doRelqController.text.trim(),
      'CauseOfRelq': _causeOfRelqController.text.trim(),
      'AOR': _aorController.text.trim(),
      'Checked': _checkedController.text.trim(),
      'PageNo': _pageNoController.text.trim(),
      'HWRemarks': _hwRemarksController.text.trim(),
      'Pic': _picController.text.trim(),
      'AccountNo': int.tryParse(_accountNoController.text.trim()) ?? 0,
    };

    try {
      if (widget.hwData == null) {
        await AdminDB.instance.insertRecord('HWO', hwData);
      } else {
        await AdminDB.instance.updateRecord(widget.hwData!['HWID'], hwData);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Record saved successfully")),
      );
    } catch (e) {
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
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff27ADF5),
        title: Text(widget.hwData == null ? "Add HWO Data" : "Edit HWO Data"),
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
                    "HWPersNo",
                    _hwPersNoController,
                    onSubmitted: (value) => _fetchFromBasicTbl(value),
                  ),
                  _buildTextField("DOAppt", _doApptController),
                  _buildTextField("ExtnUpto", _extnUptoController),
                  _buildTextField("DORelq", _doRelqController),
                  _buildTextField("CauseOfRelq", _causeOfRelqController),
                  _buildTextField("AOR", _aorController),
                  // Dropdown for Checked
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 340,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: "Checked",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        value: _checkedController.text.isNotEmpty
                            ? _checkedController.text
                            : null,
                        items: const [
                          DropdownMenuItem(value: "Yes", child: Text("Yes")),
                          DropdownMenuItem(value: "No", child: Text("No")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _checkedController.text = value ?? '';
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Required field"
                            : null,
                      ),
                    ),
                  ),
                  _buildTextField("PageNo", _pageNoController),
                  _buildTextField("HWRemarks", _hwRemarksController),
                  _buildTextField("Pic", _picController),
                  _buildTextField("AccountNo", _accountNoController),
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
                      widget.hwData == null ? "Save" : "Update Data",
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
