import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/components/delete_dialog.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class ProvinceScreen extends StatefulWidget {
  const ProvinceScreen({super.key});

  @override
  State<ProvinceScreen> createState() => _ProvinceScreenState();
}

class _ProvinceScreenState extends State<ProvinceScreen> {
  final TextEditingController _provinceNameController = TextEditingController();
  final TextEditingController _createdByController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _provinceList = [];
  int? _editingId;

  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final data = await AdminDB.instance.fetchAll('province');
    setState(() => _provinceList = data);
  }

  Future<void> _saveProvince() async {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final provinceData = {
      'name': _provinceNameController.text.trim(),
      'created_by': _createdByController.text.trim().isEmpty
          ? 'System'
          : _createdByController.text.trim(),
      'created_at': now,
      'updated_by': _createdByController.text.trim().isEmpty
          ? 'System'
          : _createdByController.text.trim(),
      'updated_at': now,
    };

    if (provinceData['name']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a province name')),
      );
      return;
    }

    if (_editingId == null) {
      await AdminDB.instance.insertRecord('province', provinceData);
    } else {
      // await AdminDB.instance.updateRecord('province', _editingId!, {
      //   ...provinceData,
      //   'updated_at': now,
      // });
    }

    _clearForm();
    _loadProvinces();
  }

  void _editProvince(Map<String, dynamic> province) {
    setState(() {
      _editingId = province['id'] is int
          ? province['id']
          : int.tryParse(province['id'].toString());
      _provinceNameController.text = province['name'] ?? '';
      _createdByController.text = province['created_by'] ?? '';
    });
  }

  void _deleteProvinceWithDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete Province',
        message: 'Are you sure you want to delete this province?',
        onConfirm: () async {
          await AdminDB.instance.deleteRecord('province', id);
          _loadProvinces();
        },
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _provinceNameController.clear();
      _createdByController.clear();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _currentPage = 0;
    });
  }

  // ---------------- FILTER + SEARCH ----------------
  List<Map<String, dynamic>> get _filteredProvinces {
    final query = _searchController.text.toLowerCase();
    final filtered = _provinceList.where((province) {
      return query.isEmpty ||
          (province['name']?.toLowerCase().contains(query) ?? false) ||
          (province['created_by']?.toLowerCase().contains(query) ?? false);
    }).toList();

    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  // ---------------- EXPORT PDF ----------------
  Future<void> _exportPDF(List<Map<String, dynamic>> data) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Table.fromTextArray(
              headers: [
                'ID',
                'Province Name',
                'Created By',
                'Created At',
                'Updated By',
                'Updated At',
              ],
              data: data.map((e) {
                return [
                  e['id'].toString(),
                  e['name'] ?? '',
                  e['created_by'] ?? '',
                  e['created_at'] ?? '',
                  e['updated_by'] ?? '',
                  e['updated_at'] ?? '',
                ];
              }).toList(),
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Province_List.pdf');
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

  // ---------------- EXPORT EXCEL ----------------
  Future<void> _exportExcel(List<Map<String, dynamic>> data) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Province_List'];

      sheet.appendRow([
        'ID',
        'Province Name',
        'Created By',
        'Created At',
        'Updated By',
        'Updated At',
      ]);

      for (var item in data) {
        sheet.appendRow([
          item['id'].toString(),
          item['name'] ?? '',
          item['created_by'] ?? '',
          item['created_at'] ?? '',
          item['updated_by'] ?? '',
          item['updated_at'] ?? '',
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/Province_List.xlsx";
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProvinces;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("Province Management"),
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
                    title: 'Clear Filter',
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
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final totalFiltered = _provinceList.where((province) {
      final query = _searchController.text.toLowerCase();
      return query.isEmpty ||
          (province['name']?.toLowerCase().contains(query) ?? false) ||
          (province['created_by']?.toLowerCase().contains(query) ?? false);
    }).length;

    final totalPages = (totalFiltered / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 0
              ? () => setState(() => _currentPage--)
              : null,
          icon: const Icon(Icons.arrow_back_ios),
        ),
        Text('Page ${_currentPage + 1} of $totalPages'),
        IconButton(
          onPressed: _currentPage < totalPages - 1
              ? () => setState(() => _currentPage++)
              : null,
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Center(
      child: SizedBox(
        width: 600,
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Province",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        _provinceNameController,
                        'Province Name',
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _saveProvince,
                      icon: const Icon(Icons.save),
                      label: Text(_editingId == null ? 'Create' : 'Update'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _clearForm,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No provinces available.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 25,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xffe8f4fd),
              ),
              dataRowMinHeight: 50,
              dataRowMaxHeight: 60,
              columns: const [
                DataColumn(label: Text("Actions")),
                DataColumn(label: Text("ID")),
                DataColumn(label: Text("Province Name")),
                DataColumn(label: Text("Created By")),
                DataColumn(label: Text("Created At")),
                DataColumn(label: Text("Updated By")),
                DataColumn(label: Text("Updated At")),
              ],
              rows: data.map((province) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editProvince(province),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProvinceWithDialog(
                              province['id'] as int,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(province['id'].toString())),
                    DataCell(Text(province['name'] ?? '')),
                    DataCell(Text(province['created_by'] ?? '')),
                    DataCell(Text(province['created_at'] ?? '')),
                    DataCell(Text(province['updated_by'] ?? '')),
                    DataCell(Text(province['updated_at'] ?? '')),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
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
