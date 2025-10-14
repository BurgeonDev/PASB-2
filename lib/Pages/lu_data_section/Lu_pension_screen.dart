import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/sqlite/lupension_database_Helper.dart';

class LuPensionScreen extends StatefulWidget {
  const LuPensionScreen({super.key});

  @override
  State<LuPensionScreen> createState() => _LuPensionScreenState();
}

class _LuPensionScreenState extends State<LuPensionScreen> {
  final TextEditingController _pensionTypeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  String? _filterCategory;
  List<Map<String, dynamic>> _pensionList = [];
  int? _editingId;

  final List<String> _categories = [
    'Retired',
    'Shaheed',
    'Family Pensioner',
    'Non-Pensioner',
    'Disabled',
  ];
  final String _pasbName = "PASB";

  @override
  void initState() {
    super.initState();
    _loadPensions();
  }

  Future<void> _loadPensions() async {
    final data = await LuPensionDatabase.instance.getAllPensions();
    setState(() {
      _pensionList = data;
    });
  }

  Future<void> _savePension() async {
    final now = DateTime.now().toIso8601String();

    final pensionData = {
      'Pension_Type': _pensionTypeController.text.trim(),
      'Pension_Category': _selectedCategory ?? '',
      'created_by': _pasbName,
      'updated_by': _pasbName,
    };

    if (_editingId == null) {
      pensionData['created_at'] = now;
      pensionData['updated_at'] = now;
      await LuPensionDatabase.instance.insertPension(pensionData);
    } else {
      pensionData['id'] = _editingId!.toString();
      pensionData['updated_at'] = now;
      await LuPensionDatabase.instance.updatePension(pensionData);
    }

    _clearForm();
    _loadPensions();
  }

  void _editPension(Map<String, dynamic> pension) {
    setState(() {
      _editingId = pension['id'] is int
          ? pension['id']
          : int.tryParse(pension['id'].toString());
      _pensionTypeController.text = pension['Pension_Type'] ?? '';
      _selectedCategory = pension['Pension_Category'];
    });
  }

  Future<void> _deletePension(int id) async {
    await LuPensionDatabase.instance.deletePension(id);
    _loadPensions();
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _pensionTypeController.clear();
      _selectedCategory = null;
    });
  }

  void _clearFilters() {
    setState(() {
      _filterCategory = null;
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

  List<Map<String, dynamic>> get _filteredPensions {
    return _pensionList.where((p) {
      final matchesCategory =
          _filterCategory == null ||
          _filterCategory!.isEmpty ||
          p['Pension_Category'] == _filterCategory;

      final query = _searchController.text.toLowerCase().trim();
      final matchesSearch =
          query.isEmpty ||
          (p['Pension_Type']?.toLowerCase().contains(query) ?? false) ||
          (p['Pension_Category']?.toLowerCase().contains(query) ?? false) ||
          (p['created_by']?.toLowerCase().contains(query) ?? false) ||
          (p['updated_by']?.toLowerCase().contains(query) ?? false);

      return matchesCategory && matchesSearch;
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
                'Pension Type',
                'Category',
                'Created By',
                'Updated By',
                'Created At',
                'Updated At',
              ],
              data: data.map((e) {
                return [
                  e['Pension_Type'] ?? '',
                  e['Pension_Category'] ?? '',
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
      final file = File('${dir.path}/LuPension_List.pdf');
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
      final sheet = excel['LuPension_List'];

      sheet.appendRow([
        'Pension Type',
        'Category',
        'Created By',
        'Updated By',
        'Created At',
        'Updated At',
      ]);

      for (var item in data) {
        sheet.appendRow([
          item['Pension_Type'] ?? '',
          item['Pension_Category'] ?? '',
          item['created_by'] ?? '',
          item['updated_by'] ?? '',
          formatDate(item['created_at']),
          formatDate(item['updated_at']),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/LuPension_List.xlsx";
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
    final filtered = _filteredPensions;
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("Pension Types Listing"),
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
                const SizedBox(width: 10),
                // DropdownButton<String>(
                //   value: _filterCategory,
                //   hint: const Text("Filter Category"),
                //   items: [
                //     const DropdownMenuItem(value: null, child: Text("All")),
                //     ..._categories
                //         .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                //         .toList(),
                //   ],
                //   onChanged: (val) => setState(() => _filterCategory = val),
                // ),
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
    return SingleChildScrollView(
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
                  value: _filterCategory,
                  hint: const Text("Pension Type"),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("Pension Types"),
                    ),
                    ..._categories.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (val) => setState(() => _filterCategory = val),
                ),
              ),

              const DataColumn(label: Text("Category")),
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
                          onPressed: () => _editPension(record),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePension(record['id']),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(record['Pension_Type'] ?? '')),
                  DataCell(Text(record['Pension_Category'] ?? '')),
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
              children: [
                Expanded(
                  child: _textField(_pensionTypeController, 'Pension Type'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pension Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: _categories
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _savePension,
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
