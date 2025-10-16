import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/sqlite/lu_regtcorps_database_Helper.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class LuRegtCorpsScreen extends StatefulWidget {
  const LuRegtCorpsScreen({super.key});

  @override
  State<LuRegtCorpsScreen> createState() => _LuRegtCorpsScreenState();
}

class _LuRegtCorpsScreenState extends State<LuRegtCorpsScreen> {
  final TextEditingController _regtCorpsIdController = TextEditingController();
  final TextEditingController _rwPhoneController = TextEditingController();
  final TextEditingController _rwAddressController = TextEditingController();
  final TextEditingController _rwAddressUrduController =
      TextEditingController();
  final TextEditingController _regtUrduController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedForce = 'Forces';
  String? _tableFilterForce;

  List<Map<String, dynamic>> _regtCorpsList = [];
  int? _editingId;

  final List<String> _forces = ['ARMY', 'NAVY', 'PAF'];
  final String _pasbName = "PASB";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await AdminDB.instance.fetchAll('Lu_Regt_Corps');

    setState(() => _regtCorpsList = data);
  }

  Future<void> _saveData() async {
    final now = DateTime.now().toIso8601String();
    final regtData = {
      'force': _selectedForce ?? '',
      'regtcorps': _regtCorpsIdController.text.trim(),
      'rw_phone': _rwPhoneController.text.trim(),
      'rw_address': _rwAddressController.text.trim(),
      'rw_address_urdu': _rwAddressUrduController.text.trim(),
      'regt_urdu': _regtUrduController.text.trim(),
      'created_by': _pasbName,
      'updated_by': _pasbName,
      'created_at': now,
      'updated_at': now,
    };

    if (_editingId == null) {
      // Insert new record into Lu_Regt_Corps table
      await AdminDB.instance.insertRecord('Lu_Regt_Corps', regtData);
      print("Inserted new record in Lu_Regt_Corps");
    } else {
      // Update existing record
      regtData['id'] = _editingId!.toString();
      regtData['updated_at'] = DateTime.now().toIso8601String();
      await AdminDB.instance.updateRecord('Lu_Regt_Corps', regtData);
      print("Updated record with ID $_editingId in Lu_Regt_Corps");
    }

    _clearForm();
    _loadData();
  }

  void _editData(Map<String, dynamic> record) {
    setState(() {
      _editingId = record['id'];
      _selectedForce = record['force'];
      _regtCorpsIdController.text = record['regtcorps'] ?? '';
      _rwPhoneController.text = record['rw_phone'] ?? '';
      _rwAddressController.text = record['rw_address'] ?? '';
      _rwAddressUrduController.text = record['rw_address_urdu'] ?? '';
      _regtUrduController.text = record['regt_urdu'] ?? '';
    });
  }

  Future<void> _deleteData(int id) async {
    await AdminDB.instance.deleteRecord('Lu_Regt_Corps', id);
    _loadData();
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedForce = 'Forces';
      _regtCorpsIdController.clear();
      _rwPhoneController.clear();
      _rwAddressController.clear();
      _rwAddressUrduController.clear();
      _regtUrduController.clear();
    });
  }

  void _clearFilters() {
    setState(() {
      _tableFilterForce = null;
      _searchController.clear();
    });
  }

  String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoString;
    }
  }

  List<Map<String, dynamic>> _applyFilters() {
    return _regtCorpsList.where((record) {
      final matchesForce =
          _tableFilterForce == null || record['force'] == _tableFilterForce;
      final search = _searchController.text.toLowerCase();
      final matchesSearch =
          search.isEmpty ||
          record['regtcorps'].toLowerCase().contains(search) ||
          record['rw_address'].toLowerCase().contains(search) ||
          record['rw_phone'].toLowerCase().contains(search);
      return matchesForce && matchesSearch;
    }).toList();
  }

  Future<void> _exportPDF(List<Map<String, dynamic>> data) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Table.fromTextArray(
              headers: [
                'Force',
                'RegtCorps',
                'RW Phone',
                'RW Address',
                'RW Address Urdu',
                'Regt Urdu',
                'Created By',
                'Updated By',
                'Created At',
                'Updated At',
              ],
              data: data.map((e) {
                return [
                  e['force'] ?? '',
                  e['regtcorps'] ?? '',
                  e['rw_phone'] ?? '',
                  e['rw_address'] ?? '',
                  e['rw_address_urdu'] ?? '',
                  e['regt_urdu'] ?? '',
                  e['created_by'] ?? '',
                  e['updated_by'] ?? '',
                  formatDate(e['created_at']),
                  formatDate(e['updated_at']),
                ];
              }).toList(),
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/LU_RegtCorps.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF exported: ${file.path}')));

      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
    }
  }

  Future<void> _exportExcel(List<Map<String, dynamic>> data) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['LU_RegtCorps'];

      sheet.appendRow([
        'Force',
        'RegtCorps',
        'RW Phone',
        'RW Address',
        'RW Address Urdu',
        'Regt Urdu',
        'Created By',
        'Updated By',
        'Created At',
        'Updated At',
      ]);

      for (var item in data) {
        sheet.appendRow([
          item['force'] ?? '',
          item['regtcorps'] ?? '',
          item['rw_phone'] ?? '',
          item['rw_address'] ?? '',
          item['rw_address_urdu'] ?? '',
          item['regt_urdu'] ?? '',
          item['created_by'] ?? '',
          item['updated_by'] ?? '',
          formatDate(item['created_at']),
          formatDate(item['updated_at']),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/LU_RegtCorps.xlsx";
      await File(path).writeAsBytes(excel.encode()!);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Excel exported: $path')));
      await OpenFilex.open(path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export Excel: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters();
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("Regt Corps Listing"),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 40,
                  child: ButtonComponent(
                    buttonColor: Colors.grey,
                    ontap: () => _exportPDF(filtered),
                    title: 'PDF',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  height: 40,
                  child: ButtonComponent(
                    buttonColor: Colors.grey,
                    ontap: () => _exportExcel(filtered),
                    title: 'Excel',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ButtonComponent(
                    buttonColor: Colors.grey,
                    ontap: _clearFilters,
                    title: 'Clear Filters',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildDataTable(filtered)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: DataTable(
              columnSpacing: 20,
              headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
              columns: [
                const DataColumn(label: Text("Actions")),
                const DataColumn(label: Text("S No.")),
                DataColumn(
                  label: DropdownButton<String>(
                    value: _tableFilterForce,
                    hint: const Text("Force"),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("All Forces"),
                      ),
                      ..._forces
                          .map(
                            (f) => DropdownMenuItem(value: f, child: Text(f)),
                          )
                          .toList(),
                    ],
                    onChanged: (value) =>
                        setState(() => _tableFilterForce = value),
                  ),
                ),
                const DataColumn(label: Text("RegtCorps")),
                const DataColumn(label: Text("RW Phone")),
                const DataColumn(label: Text("RW Address")),
                const DataColumn(label: Text("RW Address Urdu")),
                const DataColumn(label: Text("Regt Urdu")),
                const DataColumn(label: Text("Created By")),
                const DataColumn(label: Text("Updated By")),
                const DataColumn(label: Text("Created At")),
                const DataColumn(label: Text("Updated At")),
              ],
              rows: List.generate(data.length, (index) {
                final record = data[index];
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editData(record),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteData(record['id']),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text('${index + 1}')), // S No.
                    DataCell(Text(record['force'] ?? '')),
                    DataCell(Text(record['regtcorps'] ?? '')),
                    DataCell(Text(record['rw_phone'] ?? '')),
                    DataCell(Text(record['rw_address'] ?? '')),
                    DataCell(Text(record['rw_address_urdu'] ?? '')),
                    DataCell(Text(record['regt_urdu'] ?? '')),
                    DataCell(Text(record['created_by'] ?? '')),
                    DataCell(Text(record['updated_by'] ?? '')),
                    DataCell(Text(formatDate(record['created_at']))),
                    DataCell(Text(formatDate(record['updated_at']))),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟩 Column 1
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Force',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedForce == 'Forces'
                            ? null
                            : _selectedForce,
                        items: _forces
                            .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedForce = val),
                      ),
                      const SizedBox(height: 10),
                      _textField(_regtCorpsIdController, 'Regt/Corps Name'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // 🟨 Column 2
                Expanded(
                  child: Column(
                    children: [
                      _textField(_rwPhoneController, 'RW Phone'),
                      const SizedBox(height: 10),
                      _textField(_rwAddressController, 'RW Address'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // 🟦 Column 3
                Expanded(
                  child: Column(
                    children: [
                      _textField(_rwAddressUrduController, 'RW Address Urdu'),
                      const SizedBox(height: 10),
                      _textField(_regtUrduController, 'Regt/Corps Urdu'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveData,
                  icon: const Icon(Icons.save),
                  label: Text(_editingId == null ? 'Save' : 'Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.clear),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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

  Widget _textField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
