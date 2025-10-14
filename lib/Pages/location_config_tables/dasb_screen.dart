import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class DasbScreen extends StatefulWidget {
  const DasbScreen({super.key});

  @override
  State<DasbScreen> createState() => _DasbScreenState();
}

class _DasbScreenState extends State<DasbScreen> {
  final TextEditingController _dasbNameController = TextEditingController();
  final TextEditingController _createdByController = TextEditingController();

  List<Map<String, dynamic>> _dasbList = [];
  List<Map<String, dynamic>> _provinceList = [];
  List<Map<String, dynamic>> _directorateList = [];

  int? _selectedProvinceId;
  int? _selectedDirectorateId;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provinces = await AdminDB.instance.fetchAll('province');
    final dasbs = await AdminDB.instance.fetchAll('dasb');
    setState(() {
      _provinceList = provinces;
      _dasbList = dasbs;
    });
  }

  Future<void> _loadDirectoratesByProvince(int provinceId) async {
    final data = await AdminDB.instance.fetchWhere(
      'directorate',
      'province_id = ?',
      [provinceId],
    );
    setState(() {
      _directorateList = data;
      _selectedDirectorateId = null;
    });
  }

  // ---------------- CSV IMPORT ----------------
  Future<void> _importCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No file selected')));
        return;
      }

      debugPrint('result ------> $result');

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      // Try UTF8 first, fallback to Latin1 if it fails
      String csvContent;
      try {
        csvContent = const Utf8Decoder().convert(bytes);
      } catch (_) {
        csvContent = const Latin1Decoder().convert(bytes);
      }

      final csvTable = const CsvToListConverter().convert(csvContent);

      // Remove header row if present
      final List<List<dynamic>> dataRows = csvTable
          .where((row) => row.isNotEmpty && row[0].toString().trim() != 'Ser')
          .toList();

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      int insertedCount = 0;

      for (final row in dataRows) {
        if (row.length < 2) continue; // skip incomplete rows

        final dasbName = row[1].toString().trim();
        if (dasbName.isEmpty) continue;

        final dasbData = {
          'province_id': _selectedProvinceId ?? 1, // Default or change manually
          'directorate_id': _selectedDirectorateId ?? 1,
          'name': dasbName,
          'created_by': 'System',
          'created_at': now,
          'updated_by': 'System',
          'updated_at': now,
        };

        await AdminDB.instance.insertRecord('dasb', dasbData);
        insertedCount++;
      }

      _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $insertedCount DASBs successfully')),
      );
    } catch (e) {
      debugPrint('Error importing CSV: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing CSV: $e')));
    }
  }

  // ---------------- SAVE / EDIT / DELETE ----------------
  Future<void> _saveDasb() async {
    if (_selectedProvinceId == null ||
        _selectedDirectorateId == null ||
        _dasbNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final dasbData = {
      //   'province_id': _selectedProvinceId,
      'directorate_id': _selectedDirectorateId,
      'name': _dasbNameController.text.trim(),
      'created_by': _createdByController.text.trim(),
      'created_at': now,
      'updated_by': _createdByController.text.trim(),
      'updated_at': now,
    };

    if (_editingId == null) {
      await AdminDB.instance.insertRecord('dasb', dasbData);
    } else {
      dasbData['id'] = _editingId.toString();
      await AdminDB.instance.updateRecord('dasb', dasbData);
    }

    _clearForm();
    _loadData();
  }

  void _editDasb(Map<String, dynamic> dasb) {
    setState(() {
      _editingId = dasb['id'];
      _dasbNameController.text = dasb['name'] ?? '';
      _selectedProvinceId = dasb['province_id'];
      _selectedDirectorateId = dasb['directorate_id'];
    });
    _loadDirectoratesByProvince(_selectedProvinceId!);
  }

  Future<void> _deleteDasb(int id) async {
    final confirm = await _showDeleteDialog();
    if (confirm == true) {
      await AdminDB.instance.deleteRecord('dasb', id);
      _loadData();
    }
  }

  Future<bool?> _showDeleteDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this record?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _dasbNameController.clear();
      _selectedProvinceId = null;
      _selectedDirectorateId = null;
    });
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("DASB Management"),
        backgroundColor: const Color(0xff27ADF5),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.file_upload),
        //     tooltip: "Import from CSV",
        //     onPressed: _importCsv,
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(child: _buildForm()),
            const SizedBox(height: 20),
            Expanded(child: _buildDasbList()),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM ----------------
  Widget _buildForm() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Add DASB",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: _buildDropdown(
                    hint: "Select Province",
                    value: _selectedProvinceId,
                    items: _provinceList,
                    onChanged: (val) {
                      setState(() => _selectedProvinceId = val);
                      _loadDirectoratesByProvince(val!);
                    },
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 250,
                  child: _buildDropdown(
                    hint: "Select Directorate",
                    value: _selectedDirectorateId,
                    items: _directorateList,
                    onChanged: (val) =>
                        setState(() => _selectedDirectorateId = val),
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 250,
                  child: _textField(_dasbNameController, "DASB Name"),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: _saveDasb,
                  icon: const Icon(Icons.save),
                  label: Text(_editingId == null ? "Create" : "Update"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TABLE ----------------
  Widget _buildDasbList() {
    if (_dasbList.isEmpty) {
      return const Center(child: Text("No DASBs available."));
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            dataRowMaxHeight: 50,
            columns: const [
              DataColumn(label: Text("Actions")),
              DataColumn(label: Text("S No.")),
              DataColumn(label: Text("Province")),
              DataColumn(label: Text("Directorate")),
              DataColumn(label: Text("DASB Name")),
              DataColumn(label: Text("Created At")),
              DataColumn(label: Text("Updated At")),
            ],
            rows: _dasbList.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final dasb = entry.value;

              final provinceName = _provinceList.firstWhere(
                (p) => p['id'] == dasb['province_id'],
                orElse: () => {'name': ''},
              )['name'];

              final directorateName = _directorateList.firstWhere(
                (d) => d['id'] == dasb['directorate_id'],
                orElse: () => {'name': ''},
              )['name'];

              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editDasb(dasb),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteDasb(dasb['id'] as int),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(index.toString())),
                  DataCell(Text(provinceName ?? '')),
                  DataCell(Text(directorateName ?? '')),
                  DataCell(Text(dasb['name'] ?? '')),
                  DataCell(Text(_formatDate(dasb['created_at']))),
                  DataCell(Text(_formatDate(dasb['updated_at']))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required int? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: item['id'] is int
                  ? item['id']
                  : int.tryParse(item['id'].toString()),
              child: Text(item['name'] ?? ''),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
