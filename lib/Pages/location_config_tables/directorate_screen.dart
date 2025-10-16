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

class DirectorateScreen extends StatefulWidget {
  const DirectorateScreen({super.key});

  @override
  State<DirectorateScreen> createState() => _DirectorateScreenState();
}

class _DirectorateScreenState extends State<DirectorateScreen> {
  final TextEditingController _directorateNameController =
      TextEditingController();
  final TextEditingController _createdByController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _directorateList = [];
  List<Map<String, dynamic>> _provinceList = [];

  int? _selectedProvinceId;
  int? _editingId;

  int _rowsPerPage = 10;
  int _currentPage = 0;

  // Sorting
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _loadDirectorates();
  }

  Future<void> _loadProvinces() async {
    final provinces = await AdminDB.instance.fetchAll('province');
    setState(() => _provinceList = provinces);
  }

  Future<void> _loadDirectorates() async {
    final data = await AdminDB.instance.fetchAll('directorate');
    setState(() => _directorateList = data);
  }

  Future<void> _saveDirectorate() async {
    if (_selectedProvinceId == null ||
        _directorateNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final directorateData = {
      'province_id': _selectedProvinceId,
      'name': _directorateNameController.text.trim(),
      'created_by': _createdByController.text.trim().isEmpty
          ? 'System'
          : _createdByController.text.trim(),
      'created_at': now,
      'updated_by': _createdByController.text.trim().isEmpty
          ? 'System'
          : _createdByController.text.trim(),
      'updated_at': now,
    };

    if (_editingId == null) {
      await AdminDB.instance.insertRecord('directorate', directorateData);
    } else {
      // Update logic if required
    }

    _clearForm();
    _loadDirectorates();
  }

  void _editDirectorate(Map<String, dynamic> dir) {
    setState(() {
      _editingId = dir['id'] is int
          ? dir['id']
          : int.tryParse(dir['id'].toString());
      _directorateNameController.text = dir['name'] ?? '';
      _createdByController.text = dir['created_by'] ?? '';
      _selectedProvinceId = dir['province_id'] is int
          ? dir['province_id']
          : int.tryParse(dir['province_id'].toString());
    });
  }

  void _deleteDirectorateWithDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete Directorate',
        message: 'Are you sure you want to delete this directorate?',
        onConfirm: () async {
          await AdminDB.instance.deleteRecord('directorate', id);
          _loadDirectorates();
        },
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedProvinceId = null;
      _directorateNameController.clear();
      _createdByController.clear();
    });
  }

  String _getProvinceName(int? provinceId) {
    if (provinceId == null) return '';
    final province = _provinceList.firstWhere(
      (p) => p['id'] == provinceId,
      orElse: () => {},
    );
    return province['name'] ?? '';
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

  // ---------------- FILTER + SEARCH ----------------
  List<Map<String, dynamic>> get _filteredDirectorates {
    final query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> filtered = _directorateList.where((dir) {
      return query.isEmpty ||
          (dir['name']?.toLowerCase().contains(query) ?? false) ||
          (_getProvinceName(
            dir['province_id'],
          ).toLowerCase().contains(query)) ||
          (dir['created_by']?.toLowerCase().contains(query) ?? false);
    }).toList();

    // Apply sorting
    if (_sortColumnIndex != null) {
      filtered.sort((a, b) {
        dynamic valA;
        dynamic valB;
        switch (_sortColumnIndex) {
          case 2:
            valA = _getProvinceName(a['province_id']);
            valB = _getProvinceName(b['province_id']);
            break;
          case 3:
            valA = a['name'] ?? '';
            valB = b['name'] ?? '';
            break;
          case 4:
            valA = a['created_by'] ?? '';
            valB = b['created_by'] ?? '';
            break;
          default:
            valA = a['id'];
            valB = b['id'];
        }
        return _sortAscending
            ? valA.toString().compareTo(valB.toString())
            : valB.toString().compareTo(valA.toString());
      });
    }

    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _currentPage = 0;
    });
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
                'S No',
                'Province',
                'Directorate Name',
                'Created By',
                'Created At',
                'Updated By',
                'Updated At',
              ],
              data: data.asMap().entries.map((entry) {
                final index = entry.key;
                final dir = entry.value;
                return [
                  (index + 1).toString(),
                  _getProvinceName(dir['province_id']),
                  dir['name'] ?? '',
                  dir['created_by'] ?? '',
                  dir['created_at'] ?? '',
                  dir['updated_by'] ?? '',
                  dir['updated_at'] ?? '',
                ];
              }).toList(),
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Directorate_List.pdf');
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
      final sheet = excel['Directorate_List'];

      sheet.appendRow([
        'S No',
        'Province',
        'Directorate Name',
        'Created By',
        'Created At',
        'Updated By',
        'Updated At',
      ]);

      for (var i = 0; i < data.length; i++) {
        final dir = data[i];
        sheet.appendRow([
          (i + 1).toString(),
          _getProvinceName(dir['province_id']),
          dir['name'] ?? '',
          dir['created_by'] ?? '',
          dir['created_at'] ?? '',
          dir['updated_by'] ?? '',
          dir['updated_at'] ?? '',
        ]);
      }

      final dirPath = await getApplicationDocumentsDirectory();
      final path = "${dirPath.path}/Directorate_List.xlsx";
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
    final filtered = _filteredDirectorates;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("Directorate Management"),
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
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search",
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
            _buildPagination(filtered.length),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: SizedBox(
        width: 800,
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Flexible(flex: 1, child: _buildProvinceDropdown()),
                const SizedBox(width: 10),
                Expanded(
                  child: _textField(
                    _directorateNameController,
                    'Directorate Name',
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _saveDirectorate,
                  icon: const Icon(Icons.save),
                  label: Text(_editingId == null ? 'Save' : 'Update'),
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
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
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

  Widget _buildProvinceDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedProvinceId,
      decoration: const InputDecoration(
        labelText: 'Select Province',
        border: OutlineInputBorder(),
      ),
      items: _provinceList.map((province) {
        return DropdownMenuItem<int>(
          value: province['id'] as int,
          child: Text(province['name'] ?? ''),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedProvinceId = value),
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

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty)
      return const Center(child: Text('No directorates available.'));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columnSpacing: 20,
              columns: [
                const DataColumn(label: Text("Actions")),
                DataColumn(
                  label: const Text("S No"),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: const Text("Province"),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: const Text("Directorate Name"),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: const Text("Created By"),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(label: const Text("Created At")),
                DataColumn(label: const Text("Updated By")),
                DataColumn(label: const Text("Updated At")),
              ],
              rows: data.asMap().entries.map((entry) {
                final index = entry.key;
                final dir = entry.value;
                final seqNo = _currentPage * _rowsPerPage + index + 1;
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editDirectorate(dir),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteDirectorateWithDialog(dir['id'] as int),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(seqNo.toString())),
                    DataCell(Text(_getProvinceName(dir['province_id']))),
                    DataCell(Text(dir['name'] ?? '')),
                    DataCell(Text(dir['created_by'] ?? '')),
                    DataCell(Text(_formatDate(dir['created_at']))),
                    DataCell(Text(dir['updated_by'] ?? '')),
                    DataCell(Text(_formatDate(dir['updated_at']))),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / _rowsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text('Page ${_currentPage + 1} of $totalPages'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }
}
