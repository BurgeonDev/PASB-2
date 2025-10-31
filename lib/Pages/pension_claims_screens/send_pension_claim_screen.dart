import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:testing_window_app/components/toast_message.dart';
import 'package:testing_window_app/sqlite/pansion_claims_db.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class SendPensionClaimScreen extends StatefulWidget {
  const SendPensionClaimScreen({super.key});

  @override
  State<SendPensionClaimScreen> createState() => _SendPensionClaimScreenState();
}

class _SendPensionClaimScreenState extends State<SendPensionClaimScreen> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown selections
  String? selectedFrom;
  String? selectedTo;
  String? selectedRelation;

  // Text controllers
  final TextEditingController pensionIdController = TextEditingController();
  final TextEditingController pensionNumberController = TextEditingController();
  final TextEditingController claimantController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Dropdown lists
  final List<String> fromLocations = [
    'Rwp',
    'Gujrat',
    'Jhelum',
    'Attock',
    'Chakwal',
  ];
  final List<String> toLocations = [
    'AC Cen',
    'FF Cen',
    'BR Cen',
    'Ak Cen',
    'Art Cen',
  ];
  final List<String> relations = ['Father', 'Brother', 'Wife', 'Sister'];

  File? selectedFile;

  @override
  void initState() {
    super.initState();
    // Set current date
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    pensionIdController.dispose();
    pensionNumberController.dispose();
    claimantController.dispose();
    dateController.dispose();
    messageController.dispose();
    super.dispose();
  }

  String? uploadedFileName;
  String? uploadedFilePath;
  void _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        uploadedFilePath = result.files.single.path!;
        selectedFile = File(result.files.single.path!);
        uploadedFileName = result.files.single.name;
        selectedFile = File(uploadedFilePath!);
      });
      ToastMessage.showSuccess(context, 'Document uploaded successfully!');
    }
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final claim = {
        'fromPerson': selectedFrom,
        'toPerson': selectedTo,
        'pensionId': pensionIdController.text,
        'pensionNumber': pensionNumberController.text,
        'claimant': claimantController.text,
        'relation': selectedRelation,
        'date': dateController.text,
        'message': messageController.text,
        'uploadedFileName': uploadedFileName ?? '',
        'uploadedFilePath': uploadedFilePath ?? '',
      };
      print('calim body ---> ${claim.toString()}');

      await AdminDB.instance.insertRecord('pension_claims', claim);
      ToastMessage.showSuccess(context, 'Claim submitted successfully!');

      _formKey.currentState!.reset();
    }
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedValue,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
              validator: (value) =>
                  value == null ? "Please select $label" : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: controller,
              readOnly: readOnly,
              maxLines: maxLines,
              validator: (value) =>
                  value!.isEmpty ? "Please enter $label" : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Send Pension Claim"),
        backgroundColor: Colors.blueAccent,
        // centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Row 1: From - To
                Row(
                  children: [
                    _buildDropdown(
                      label: "From",
                      items: fromLocations,
                      selectedValue: selectedFrom,
                      onChanged: (val) => setState(() => selectedFrom = val),
                    ),
                    _buildDropdown(
                      label: "To",
                      items: toLocations,
                      selectedValue: selectedTo,
                      onChanged: (val) => setState(() => selectedTo = val),
                    ),
                  ],
                ),
                // Row 2: Pension ID - Pension Number
                Row(
                  children: [
                    _buildTextField(
                      label: "Pension ID",
                      controller: pensionIdController,
                    ),
                    _buildTextField(
                      label: "Pension Number",
                      controller: pensionNumberController,
                    ),
                  ],
                ),
                // Row 3: Claimant - Relation
                Row(
                  children: [
                    _buildTextField(
                      label: "Claimant",
                      controller: claimantController,
                    ),
                    _buildDropdown(
                      label: "Relation",
                      items: relations,
                      selectedValue: selectedRelation,
                      onChanged: (val) =>
                          setState(() => selectedRelation = val),
                    ),
                  ],
                ),
                // Row 4: Date
                // Row: Date + Upload Document
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Field
                    _buildTextField(
                      label: "Date",
                      controller: dateController,
                      readOnly: true,
                    ),
                    const SizedBox(width: 16),

                    // Upload Document Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Upload Document",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton.icon(
                              onPressed: _uploadDocument,
                              icon: const Icon(Icons.upload_file),
                              label: Text(uploadedFileName ?? "Choose File"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Message Field Below
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Message",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Enter message or description...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Submit Claim",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
