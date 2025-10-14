import 'package:flutter/material.dart';
import 'package:testing_window_app/components/textfield_component.dart';

import 'package:testing_window_app/sqlite/pensiontbll_database_Helper.dart';
import 'package:testing_window_app/sqlite/user_database_helper.dart';

class PensiontblDataScreen extends StatefulWidget {
  final Map<String, dynamic>? pensionData;
  const PensiontblDataScreen({super.key, this.pensionData});

  @override
  State<PensiontblDataScreen> createState() => _PensiontblDataScreenState();
}

class _PensiontblDataScreenState extends State<PensiontblDataScreen> {
  final _formKey = GlobalKey<FormState>();

  // ✅ Controllers for PensionTbl fields
  final TextEditingController _penExNoController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _penDOEntryController = TextEditingController();
  final TextEditingController _regSerNoController = TextEditingController();
  final TextEditingController _gpInsuranceClaimLtrDateController =
      TextEditingController();
  final TextEditingController _benFundClaimLtrNoController =
      TextEditingController();
  final TextEditingController _benFundClaimLtrDateController =
      TextEditingController();
  final TextEditingController _dasbLtrNoController = TextEditingController();
  final TextEditingController _dasbLtrDateController = TextEditingController();
  final TextEditingController _finalizedDateController =
      TextEditingController();
  final TextEditingController _particularsOfHWOController =
      TextEditingController();
  final TextEditingController _originatorController = TextEditingController();
  final TextEditingController _originatorLtrNoController =
      TextEditingController();
  final TextEditingController _originatorLtrDateController =
      TextEditingController();
  final TextEditingController _originatorResponseController =
      TextEditingController();
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _pensionCaseRemarksController =
      TextEditingController();
  final TextEditingController _verifiedByController = TextEditingController();
  final TextEditingController _firstWitnessController = TextEditingController();
  final TextEditingController _secondWitnessController =
      TextEditingController();
  final TextEditingController _domarriageController = TextEditingController();
  final TextEditingController _nextNOKNameController = TextEditingController();
  final TextEditingController _nextNOKRelationController =
      TextEditingController();
  final TextEditingController _nextNOKCNICNoController =
      TextEditingController();
  final TextEditingController _urduNameController = TextEditingController();
  final TextEditingController _urduFatherNameController =
      TextEditingController();
  final TextEditingController _urduNOKNameController = TextEditingController();
  final TextEditingController _urduNextNOKNameController =
      TextEditingController();
  final TextEditingController _urduNextNOKRelationController =
      TextEditingController();
  final TextEditingController _urduRelationController = TextEditingController();
  final TextEditingController _urduVillageController = TextEditingController();
  final TextEditingController _urduPostOfficeController =
      TextEditingController();
  final TextEditingController _urduTehController = TextEditingController();
  final TextEditingController _urduDisttController = TextEditingController();
  final TextEditingController _urduPresentAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.pensionData != null) {
      final data = widget.pensionData!;
      _penExNoController.text = data['PenExNo'] ?? '';
      _statusController.text = data['Status']?.toString() ?? '';
      _penDOEntryController.text = data['PenDOEntry'] ?? '';
      _regSerNoController.text = data['RegSerNo']?.toString() ?? '';
      _gpInsuranceClaimLtrDateController.text =
          data['GpInsuranceClaimLtrDate'] ?? '';
      _benFundClaimLtrNoController.text = data['BenFundClaimLtrNo'] ?? '';
      _benFundClaimLtrDateController.text = data['BenFundClaimLtrDate'] ?? '';
      _dasbLtrNoController.text = data['DASBLtrNo'] ?? '';
      _dasbLtrDateController.text = data['DASBLtrDate'] ?? '';
      _finalizedDateController.text = data['FinalizedDate'] ?? '';
      _particularsOfHWOController.text = data['ParticularsOfHWO'] ?? '';
      _originatorController.text = data['Originator'] ?? '';
      _originatorLtrNoController.text = data['OriginatorLtrNo'] ?? '';
      _originatorLtrDateController.text = data['OriginatorLtrDate'] ?? '';
      _originatorResponseController.text = data['OriginatorResponse'] ?? '';
      _historyController.text = data['History'] ?? '';
      _pensionCaseRemarksController.text = data['PensionCaseRemarks'] ?? '';
      _verifiedByController.text = data['VerifiedBy']?.toString() ?? '';
      _firstWitnessController.text = data['FirstWitness']?.toString() ?? '';
      _secondWitnessController.text = data['SecondWitness']?.toString() ?? '';
      _domarriageController.text = data['DOMarriage'] ?? '';
      _nextNOKNameController.text = data['NextNOKName'] ?? '';
      _nextNOKRelationController.text = data['NextNOKRelation'] ?? '';
      _nextNOKCNICNoController.text = data['NextNOKCNICNo'] ?? '';
      _urduNameController.text = data['UrduName'] ?? '';
      _urduFatherNameController.text = data['UrduFatherName'] ?? '';
      _urduNOKNameController.text = data['UrduNOKName'] ?? '';
      _urduNextNOKNameController.text = data['UrduNextNOKName'] ?? '';
      _urduNextNOKRelationController.text = data['UrduNextNOKRelation'] ?? '';
      _urduRelationController.text = data['UrduRelation'] ?? '';
      _urduVillageController.text = data['UrduVillage'] ?? '';
      _urduPostOfficeController.text = data['UrduPostOffice'] ?? '';
      _urduTehController.text = data['UrduTeh'] ?? '';
      _urduDisttController.text = data['UrduDistt'] ?? '';
      _urduPresentAddressController.text = data['UrduPresentAddress'] ?? '';
    }
  }

  @override
  void dispose() {
    _penExNoController.dispose();
    _statusController.dispose();
    _penDOEntryController.dispose();
    _regSerNoController.dispose();
    _gpInsuranceClaimLtrDateController.dispose();
    _benFundClaimLtrNoController.dispose();
    _benFundClaimLtrDateController.dispose();
    _dasbLtrNoController.dispose();
    _dasbLtrDateController.dispose();
    _finalizedDateController.dispose();
    _particularsOfHWOController.dispose();
    _originatorController.dispose();
    _originatorLtrNoController.dispose();
    _originatorLtrDateController.dispose();
    _originatorResponseController.dispose();
    _historyController.dispose();
    _pensionCaseRemarksController.dispose();
    _verifiedByController.dispose();
    _firstWitnessController.dispose();
    _secondWitnessController.dispose();
    _domarriageController.dispose();
    _nextNOKNameController.dispose();
    _nextNOKRelationController.dispose();
    _nextNOKCNICNoController.dispose();
    _urduNameController.dispose();
    _urduFatherNameController.dispose();
    _urduNOKNameController.dispose();
    _urduNextNOKNameController.dispose();
    _urduNextNOKRelationController.dispose();
    _urduRelationController.dispose();
    _urduVillageController.dispose();
    _urduPostOfficeController.dispose();
    _urduTehController.dispose();
    _urduDisttController.dispose();
    _urduPresentAddressController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _penExNoController.clear();
    _statusController.clear();
    _penDOEntryController.clear();
    _regSerNoController.clear();
    _gpInsuranceClaimLtrDateController.clear();
    _benFundClaimLtrNoController.clear();
    _benFundClaimLtrDateController.clear();
    _dasbLtrNoController.clear();
    _dasbLtrDateController.clear();
    _finalizedDateController.clear();
    _particularsOfHWOController.clear();
    _originatorController.clear();
    _originatorLtrNoController.clear();
    _originatorLtrDateController.clear();
    _originatorResponseController.clear();
    _historyController.clear();
    _pensionCaseRemarksController.clear();
    _verifiedByController.clear();
    _firstWitnessController.clear();
    _secondWitnessController.clear();
    _domarriageController.clear();
    _nextNOKNameController.clear();
    _nextNOKRelationController.clear();
    _nextNOKCNICNoController.clear();
    _urduNameController.clear();
    _urduFatherNameController.clear();
    _urduNOKNameController.clear();
    _urduNextNOKNameController.clear();
    _urduNextNOKRelationController.clear();
    _urduRelationController.clear();
    _urduVillageController.clear();
    _urduPostOfficeController.clear();
    _urduTehController.clear();
    _urduDisttController.clear();
    _urduPresentAddressController.clear();

    setState(() {});
  }

  Future<void> _saveDataToDb() async {
    if (!_formKey.currentState!.validate()) return;

    final pensionData = {
      'PenExNo': _penExNoController.text.trim(),
      'Status': _statusController.text.trim(),
      'PenDOEntry': _penDOEntryController.text.trim(),
      'RegSerNo': _regSerNoController.text.trim(),
      'GpInsuranceClaimLtrDate': _gpInsuranceClaimLtrDateController.text.trim(),
      'BenFundClaimLtrNo': _benFundClaimLtrNoController.text.trim(),
      'BenFundClaimLtrDate': _benFundClaimLtrDateController.text.trim(),
      'DASBLtrNo': _dasbLtrNoController.text.trim(),
      'DASBLtrDate': _dasbLtrDateController.text.trim(),
      'FinalizedDate': _finalizedDateController.text.trim(),
      'ParticularsOfHWO': _particularsOfHWOController.text.trim(),
      'Originator': _originatorController.text.trim(),
      'OriginatorLtrNo': _originatorLtrNoController.text.trim(),
      'OriginatorLtrDate': _originatorLtrDateController.text.trim(),
      'OriginatorResponse': _originatorResponseController.text.trim(),
      'History': _historyController.text.trim(),
      'PensionCaseRemarks': _pensionCaseRemarksController.text.trim(),
      'VerifiedBy': _verifiedByController.text.trim(),
      'FirstWitness': _firstWitnessController.text.trim(),
      'SecondWitness': _secondWitnessController.text.trim(),
      'DOMarriage': _domarriageController.text.trim(),
      'NextNOKName': _nextNOKNameController.text.trim(),
      'NextNOKRelation': _nextNOKRelationController.text.trim(),
      'NextNOKCNICNo': _nextNOKCNICNoController.text.trim(),
      'UrduName': _urduNameController.text.trim(),
      'UrduFatherName': _urduFatherNameController.text.trim(),
      'UrduNOKName': _urduNOKNameController.text.trim(),
      'UrduNextNOKName': _urduNextNOKNameController.text.trim(),
      'UrduNextNOKRelation': _urduNextNOKRelationController.text.trim(),
      'UrduRelation': _urduRelationController.text.trim(),
      'UrduVillage': _urduVillageController.text.trim(),
      'UrduPostOffice': _urduPostOfficeController.text.trim(),
      'UrduTeh': _urduTehController.text.trim(),
      'UrduDistt': _urduDisttController.text.trim(),
      'UrduPresentAddress':
          "${_urduVillageController.text}, ${_urduPostOfficeController.text}, ${_urduTehController.text}, ${_urduDisttController.text}",
    };

    try {
      if (widget.pensionData == null) {
        await PensionDB.instance.insertPension(pensionData);
      } else {
        await PensionDB.instance.updatePension(
          widget.pensionData!['FPID'],
          pensionData,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Record saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving record: $e')));
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Textfieldcomponent(
        hinttext: label,
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? "Required field" : null,
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
          widget.pensionData == null ? "Add Pension Data" : "Edit Pension Data",
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
                  _buildTextField("PenExNo", _penExNoController),
                  // Status Dropdown
                  SizedBox(
                    width: 340,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Status",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      value: _statusController.text.isNotEmpty
                          ? _statusController.text
                          : null,
                      items: const [
                        DropdownMenuItem(
                          value: "initiated",
                          child: Text("Initiated"),
                        ),
                        DropdownMenuItem(
                          value: "accepted",
                          child: Text("Accepted"),
                        ),
                        DropdownMenuItem(
                          value: "rejected",
                          child: Text("Rejected"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusController.text = value ?? '';
                        });
                      },
                    ),
                  ),
                  _buildTextField("PenDOEntry", _penDOEntryController),
                  _buildTextField("RegSerNo", _regSerNoController),
                  _buildTextField(
                    "GpInsuranceClaimLtrDate",
                    _gpInsuranceClaimLtrDateController,
                  ),
                  _buildTextField(
                    "BenFundClaimLtrNo",
                    _benFundClaimLtrNoController,
                  ),
                  _buildTextField(
                    "BenFundClaimLtrDate",
                    _benFundClaimLtrDateController,
                  ),
                  _buildTextField("DASBLtrNo", _dasbLtrNoController),
                  _buildTextField("DASBLtrDate", _dasbLtrDateController),
                  _buildTextField("FinalizedDate", _finalizedDateController),
                  _buildTextField(
                    "ParticularsOfHWO",
                    _particularsOfHWOController,
                  ),
                  _buildTextField("Originator", _originatorController),
                  _buildTextField(
                    "OriginatorLtrNo",
                    _originatorLtrNoController,
                  ),
                  _buildTextField(
                    "OriginatorLtrDate",
                    _originatorLtrDateController,
                  ),
                  _buildTextField(
                    "OriginatorResponse",
                    _originatorResponseController,
                  ),
                  _buildTextField("History", _historyController),
                  _buildTextField(
                    "PensionCaseRemarks",
                    _pensionCaseRemarksController,
                  ),
                  _buildTextField("VerifiedBy", _verifiedByController),
                  _buildTextField("FirstWitness", _firstWitnessController),
                  _buildTextField("SecondWitness", _secondWitnessController),
                  _buildTextField("DOMarriage", _domarriageController),
                  _buildTextField("NextNOKName", _nextNOKNameController),
                  // NextNOKRelation Dropdown
                  SizedBox(
                    width: 340,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "NextNOKRelation",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      value: _nextNOKRelationController.text.isNotEmpty
                          ? _nextNOKRelationController.text
                          : null,
                      items: const [
                        DropdownMenuItem(
                          value: "brother",
                          child: Text("Brother"),
                        ),
                        DropdownMenuItem(
                          value: "mother",
                          child: Text("Mother"),
                        ),
                        DropdownMenuItem(
                          value: "father",
                          child: Text("Father"),
                        ),
                        DropdownMenuItem(value: "wife", child: Text("Wife")),
                        DropdownMenuItem(value: "son", child: Text("Son")),
                        DropdownMenuItem(
                          value: "daughter",
                          child: Text("Daughter"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _nextNOKRelationController.text = value ?? '';
                        });
                      },
                    ),
                  ),
                  _buildTextField("NextNOKCNICNo", _nextNOKCNICNoController),
                  _buildTextField("UrduName", _urduNameController),
                  _buildTextField("UrduFatherName", _urduFatherNameController),
                  _buildTextField("UrduNOKName", _urduNOKNameController),
                  _buildTextField(
                    "UrduNextNOKName",
                    _urduNextNOKNameController,
                  ),
                  _buildTextField(
                    "UrduNextNOKRelation",
                    _urduNextNOKRelationController,
                  ),
                  _buildTextField("UrduRelation", _urduRelationController),
                  _buildTextField("UrduVillage", _urduVillageController),
                  _buildTextField("UrduPostOffice", _urduPostOfficeController),
                  _buildTextField("UrduTeh", _urduTehController),
                  _buildTextField("UrduDistt", _urduDisttController),
                  _buildTextField(
                    "UrduPresentAddress",
                    _urduPresentAddressController,
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
                      widget.pensionData == null ? "Save" : "Update Data",
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
