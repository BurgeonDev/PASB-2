import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/components/delete_dialog.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/bank_db.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _abbreviationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _bankList = [];
  int? _editingId;

  String? _filterAbbreviation;
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    final data = await BankDB.instance.fetchBanks();
    setState(() => _bankList = data);
  }

  Future<void> _saveBank() async {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final bankData = {
      'name': _bankNameController.text.trim(),
      'abbreviation': _abbreviationController.text.trim(),
      'created_by': 'System',
      'created_at': now,
      'updated_by': 'System',
      'updated_at': now,
    };

    if (bankData['name']!.isEmpty || bankData['abbreviation']!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_editingId == null) {
      await BankDB.instance.insertBank(bankData);
    } else {
      await BankDB.instance.updateBank(_editingId!, {
        ...bankData,
        'updated_at': now,
      });
    }

    _clearForm();
    _loadBanks();
  }

  void _editBank(Map<String, dynamic> bank) {
    setState(() {
      _editingId = bank['id'];
      _bankNameController.text = bank['name'] ?? '';
      _abbreviationController.text = bank['abbreviation'] ?? '';
    });
  }

  void _deleteBankWithDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete Bank',
        message: 'Are you sure you want to delete this bank?',
        onConfirm: () async {
          await BankDB.instance.deleteBank(id);
          _loadBanks();
        },
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _bankNameController.clear();
      _abbreviationController.clear();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterAbbreviation = null;
      _currentPage = 0;
    });
  }

  // ---------------- FILTER + SEARCH ----------------
  List<Map<String, dynamic>> get _filteredBanks {
    final query = _searchController.text.toLowerCase();
    final filtered = _bankList.where((bank) {
      final matchesSearch =
          query.isEmpty ||
          (bank['name']?.toLowerCase().contains(query) ?? false) ||
          (bank['abbreviation']?.toLowerCase().contains(query) ?? false);
      final matchesFilter =
          _filterAbbreviation == null ||
          _filterAbbreviation!.isEmpty ||
          bank['abbreviation'] == _filterAbbreviation;
      return matchesSearch && matchesFilter;
    }).toList();

    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  List<String> get _uniqueAbbreviations {
    final abbreviations = _bankList
        .map((b) => b['abbreviation']?.toString() ?? '')
        .toSet();
    abbreviations.remove('');
    return abbreviations.toList();
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
                'Bank Name',
                'Abbreviation',
                'Created By',
                'Created At',
                'Updated By',
                'Updated At',
              ],
              data: data.map((e) {
                return [
                  e['id'].toString(),
                  e['name'] ?? '',
                  e['abbreviation'] ?? '',
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
      final file = File('${dir.path}/Bank_List.pdf');
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
      final sheet = excel['Bank_List'];

      sheet.appendRow([
        'ID',
        'Bank Name',
        'Abbreviation',
        'Created By',
        'Created At',
        'Updated By',
        'Updated At',
      ]);

      for (var item in data) {
        sheet.appendRow([
          item['id'].toString(),
          item['name'] ?? '',
          item['abbreviation'] ?? '',
          item['created_by'] ?? '',
          item['created_at'] ?? '',
          item['updated_by'] ?? '',
          item['updated_at'] ?? '',
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/Bank_List.xlsx";
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
    final filtered = _filteredBanks;
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("Bank Management"),
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
                    ontap: () {
                      _exportPDF(filtered);
                    },
                    title: 'PDF',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  height: 40,
                  child: ButtonComponent(
                    buttonColor: Colors.grey,
                    ontap: () {
                      _exportExcel(filtered);
                    },
                    title: 'Excel',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ButtonComponent(
                    buttonColor: Colors.grey,
                    ontap: () {
                      _clearFilters();
                    },
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
                const SizedBox(width: 10),
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
    final totalFiltered = _bankList.where((bank) {
      final query = _searchController.text.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          (bank['name']?.toLowerCase().contains(query) ?? false) ||
          (bank['abbreviation']?.toLowerCase().contains(query) ?? false);
      final matchesFilter =
          _filterAbbreviation == null ||
          _filterAbbreviation!.isEmpty ||
          bank['abbreviation'] == _filterAbbreviation;
      return matchesSearch && matchesFilter;
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

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No banks available.'));
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
                DataColumn(label: Text("Bank Name")),
                DataColumn(label: Text("Abbreviation")),
                DataColumn(label: Text("Created By")),
                DataColumn(label: Text("Created At")),
                DataColumn(label: Text("Updated By")),
                DataColumn(label: Text("Updated At")),
              ],
              rows: data.map((bank) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editBank(bank),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteBankWithDialog(bank['id'] as int),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(bank['id'].toString())),
                    DataCell(Text(bank['name'] ?? '')),
                    DataCell(Text(bank['abbreviation'] ?? '')),
                    DataCell(Text(bank['created_by'] ?? '')),
                    DataCell(Text(bank['created_at'] ?? '')),
                    DataCell(Text(bank['updated_by'] ?? '')),
                    DataCell(Text(bank['updated_at'] ?? '')),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
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
                  "Add Bank",
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
                      child: _textField(_bankNameController, 'Bank Name'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _textField(
                        _abbreviationController,
                        'Abbreviation',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saveBank,
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
