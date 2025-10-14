import 'package:flutter/material.dart';
import 'package:testing_window_app/components/textfield_component.dart';
import 'package:testing_window_app/sqlite/user_database_helper.dart';

class PensionMergerFormScreen extends StatefulWidget {
  final Map<String, dynamic>? pensionData;
  const PensionMergerFormScreen({super.key, this.pensionData});

  @override
  State<PensionMergerFormScreen> createState() =>
      _PensionMergerFormScreenState();
}

class _PensionMergerFormScreenState extends State<PensionMergerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _armyNoController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _regtCorpsController = TextEditingController();
  final TextEditingController _dateOfDischController = TextEditingController();
  final TextEditingController _dateOfDeathController = TextEditingController();
  final TextEditingController _placeOfDeathController = TextEditingController();
  final TextEditingController _causeOfDeathController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _tehsilController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _presentAddressController =
      TextEditingController();

  // NOK Info
  final TextEditingController _pensionTypeController = TextEditingController();
  final TextEditingController _nokNameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _domController = TextEditingController();
  final TextEditingController _nokCnicController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _idMarksController = TextEditingController();
  final TextEditingController _nextNokNameController = TextEditingController();
  final TextEditingController _nextNokRelationController =
      TextEditingController();
  final TextEditingController _nextNokCnicController = TextEditingController();
  final TextEditingController _genRemarksController = TextEditingController();
  final TextEditingController _dasbLtrNoController = TextEditingController();
  final TextEditingController _dasbLtrDateController = TextEditingController();

  // Urdu Section
  final TextEditingController _urduNameController = TextEditingController();
  final TextEditingController _urduFatherNameController =
      TextEditingController();
  final TextEditingController _urduRelationController = TextEditingController();
  final TextEditingController _urduNokNameController = TextEditingController();
  final TextEditingController _urduNextNokNameController =
      TextEditingController();
  final TextEditingController _urduNextNokRelationController =
      TextEditingController();
  final TextEditingController _urduVillageController = TextEditingController();
  final TextEditingController _urduPostOfficeController =
      TextEditingController();
  final TextEditingController _urduTehController = TextEditingController();
  final TextEditingController _urduDisttController = TextEditingController();
  final TextEditingController _urduPresentAddressController =
      TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _armyNoController,
      _rankController,
      _nameController,
      _fatherNameController,
      _regtCorpsController,
      _dateOfDischController,
      _dateOfDeathController,
      _placeOfDeathController,
      _causeOfDeathController,
      _cnicController,
      _villageController,
      _postOfficeController,
      _tehsilController,
      _districtController,
      _presentAddressController,
      _pensionTypeController,
      _nokNameController,
      _relationController,
      _dobController,
      _domController,
      _nokCnicController,
      _mobileController,
      _idMarksController,
      _nextNokNameController,
      _nextNokRelationController,
      _nextNokCnicController,
      _genRemarksController,
      _dasbLtrNoController,
      _dasbLtrDateController,
      _urduNameController,
      _urduFatherNameController,
      _urduRelationController,
      _urduNokNameController,
      _urduNextNokNameController,
      _urduNextNokRelationController,
      _urduVillageController,
      _urduPostOfficeController,
      _urduTehController,
      _urduDisttController,
      _urduPresentAddressController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // When user types Army No, check if complete & fetch data
    _armyNoController.addListener(() {
      if (_armyNoController.text.length >= 5) {
        // or your actual length
        _fetchBasicData(_armyNoController.text.trim());
      }
    });
  }

  Future<void> _fetchBasicData(String armyNo) async {
    final data = await DatabaseHelper2.instance.getRecordByPersonalNo(armyNo);

    if (data != null) {
      setState(() {
        // ===== Personal Info =====
        _rankController.text = data['rank'] ?? '';
        _nameController.text = data['name'] ?? '';
        _fatherNameController.text = data['father_name'] ?? '';
        _regtCorpsController.text = data['regt'] ?? '';
        _dateOfDischController.text = data['do_disch'] ?? '';
        _dateOfDeathController.text = data['do_death'] ?? '';
        _placeOfDeathController.text = data['place_death'] ?? '';
        _causeOfDeathController.text = data['cause_death'] ?? '';
        _cnicController.text = data['cnic'] ?? '';
        _villageController.text = data['village'] ?? '';
        _postOfficeController.text = data['post_office'] ?? '';
        _tehsilController.text = data['tehsil'] ?? '';
        _districtController.text = data['district'] ?? '';
        _presentAddressController.text = data['present_addr'] ?? '';

        // ===== NOK Info =====
        _pensionTypeController.text = data['type_of_pension'] ?? '';
        _nokNameController.text = data['nok_name'] ?? '';
        _relationController.text = data['nok_relation'] ?? '';
        _dobController.text = data['dob'] ?? '';
        _nokCnicController.text = data['nok_cnic'] ?? '';
        _mobileController.text = data['mobile'] ?? '';
        _idMarksController.text = data['id_marks'] ?? '';
        _genRemarksController.text = data['gen_remarks'] ?? '';
        _dasbLtrNoController.text = data['dasb'] ?? '';

        // ===== Urdu Section (kept empty since not in DB) =====
        _urduNameController.text = '';
        _urduFatherNameController.text = '';
        _urduRelationController.text = '';
        _urduNokNameController.text = '';
        _urduNextNokNameController.text = '';
        _urduNextNokRelationController.text = '';
        _urduVillageController.text = '';
        _urduPostOfficeController.text = '';
        _urduTehController.text = '';
        _urduDisttController.text = '';
        _urduPresentAddressController.text = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data loaded for Army No: $armyNo")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No record found for Army No: $armyNo")),
      );
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    VoidCallback? onSubmit,
  }) {
    return Textfieldcomponent(
      borderColor: Colors.grey,
      hinttext: label,
      controller: controller,
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
      onSubmitted: (_) => onSubmit?.call(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pension Merger Form'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- Column 1 ----------------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Personal Information"),
                        _buildTextField(
                          "Army No",
                          _armyNoController,
                          onSubmit: () {
                            if (_armyNoController.text.isNotEmpty) {
                              _fetchBasicData(_armyNoController.text.trim());
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        _buildTextField("Rank", _rankController),
                        SizedBox(height: 10),
                        _buildTextField("Name", _nameController),
                        SizedBox(height: 10),
                        _buildTextField("Father Name", _fatherNameController),
                        SizedBox(height: 10),
                        _buildTextField("Regt/Corps", _regtCorpsController),
                        SizedBox(height: 10),
                        _buildTextField(
                          "Date of Discharge",
                          _dateOfDischController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          "Date of Death",
                          _dateOfDeathController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          "Place of Death",
                          _placeOfDeathController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          "Cause of Death",
                          _causeOfDeathController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField("CNIC", _cnicController),
                        SizedBox(height: 10),
                        _buildSectionTitle("Address Info"),

                        _buildTextField("Village", _villageController),
                        SizedBox(height: 10),
                        _buildTextField("Post Office", _postOfficeController),
                        SizedBox(height: 10),
                        _buildTextField("Tehsil", _tehsilController),
                        SizedBox(height: 10),
                        _buildTextField("District", _districtController),
                        SizedBox(height: 10),
                        _buildTextField(
                          "Present Address",
                          _presentAddressController,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ---------------- Column 2 ----------------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Next of Kin (NOK) Details"),
                        _buildTextField("Pension Type", _pensionTypeController),
                        SizedBox(height: 10),
                        _buildTextField("NOK Name", _nokNameController),
                        SizedBox(height: 10),
                        _buildTextField("Relation", _relationController),
                        SizedBox(height: 10),
                        _buildTextField("Date of Birth", _dobController),
                        SizedBox(height: 10),
                        _buildTextField("Date of Marriage", _domController),
                        SizedBox(height: 10),
                        _buildTextField("NOK CNIC", _nokCnicController),
                        SizedBox(height: 10),
                        _buildTextField("Mobile No", _mobileController),
                        SizedBox(height: 10),
                        _buildTextField("ID Marks", _idMarksController),
                        SizedBox(height: 10),
                        _buildTextField(
                          "Next NOK Name",
                          _nextNokNameController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          "Next NOK Relation",
                          _nextNokRelationController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          "Next NOK CNIC",
                          _nextNokCnicController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          "General Remarks",
                          _genRemarksController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField("DASB Letter No", _dasbLtrNoController),
                        SizedBox(height: 10),
                        _buildTextField(
                          "DASB Letter Date",
                          _dasbLtrDateController,
                        ),
                        const Divider(),
                        _buildSectionTitle("اردو معلومات (Urdu Info)"),
                        _buildTextField("نام", _urduNameController),
                        SizedBox(height: 10),
                        _buildTextField("ولدیت", _urduFatherNameController),
                        SizedBox(height: 10),
                        _buildTextField("رشتہ", _urduRelationController),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ---------------- Column 3 ----------------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          "اردو نیکسٹ آف کن معلومات (Urdu NOK Info)",
                        ),
                        _buildTextField("نک نام", _urduNokNameController),
                        SizedBox(height: 10),
                        _buildTextField(
                          "اگلا نک نام",
                          _urduNextNokNameController,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          "اگلا نک رشتہ",
                          _urduNextNokRelationController,
                        ),
                        SizedBox(height: 10),
                        const Divider(),
                        _buildSectionTitle("اردو پتہ (Urdu Address Info)"),
                        _buildTextField("گاؤں", _urduVillageController),
                        SizedBox(height: 10),
                        _buildTextField("ڈاک خانہ", _urduPostOfficeController),
                        SizedBox(height: 10),
                        _buildTextField("تحصیل", _urduTehController),
                        SizedBox(height: 10),
                        _buildTextField("ضلع", _urduDisttController),
                        SizedBox(height: 10),
                        _buildTextField(
                          "موجودہ پتہ",
                          _urduPresentAddressController,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saved successfully")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _formKey.currentState!
                    .reset(); // optional (for validation reset)
                setState(() {
                  for (final c in [
                    _armyNoController,
                    _rankController,
                    _nameController,
                    _fatherNameController,
                    _regtCorpsController,
                    _dateOfDischController,
                    _dateOfDeathController,
                    _placeOfDeathController,
                    _causeOfDeathController,
                    _cnicController,
                    _villageController,
                    _postOfficeController,
                    _tehsilController,
                    _districtController,
                    _presentAddressController,
                    _pensionTypeController,
                    _nokNameController,
                    _relationController,
                    _dobController,
                    _domController,
                    _nokCnicController,
                    _mobileController,
                    _idMarksController,
                    _nextNokNameController,
                    _nextNokRelationController,
                    _nextNokCnicController,
                    _genRemarksController,
                    _dasbLtrNoController,
                    _dasbLtrDateController,
                    _urduNameController,
                    _urduFatherNameController,
                    _urduRelationController,
                    _urduNokNameController,
                    _urduNextNokNameController,
                    _urduNextNokRelationController,
                    _urduVillageController,
                    _urduPostOfficeController,
                    _urduTehController,
                    _urduDisttController,
                    _urduPresentAddressController,
                  ]) {
                    c.clear();
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Form cleared successfully")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
              ),
              child: const Text("Reset", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
