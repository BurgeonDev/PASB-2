import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testing_window_app/components/delete_dialog.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class UcScreen extends StatefulWidget {
  const UcScreen({super.key});

  @override
  State<UcScreen> createState() => _UcScreenState();
}

class _UcScreenState extends State<UcScreen> {
  final TextEditingController _ucNameController = TextEditingController();
  int? _selectedTehsilId;
  int? _editingId;

  List<Map<String, dynamic>> _tehsilList = [];
  List<Map<String, dynamic>> _ucList = [];

  int _currentPage = 0;
  final int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadTehsils();
    _loadUcs();
  }

  Future<void> _loadTehsils() async {
    final data = await AdminDB.instance.fetchAll('tehsil');
    setState(() => _tehsilList = data);
  }

  Future<void> _loadUcs() async {
    final data = await AdminDB.instance.fetchAll('uc');
    setState(() => _ucList = data);
  }

  Future<void> _saveUc() async {
    if (_selectedTehsilId == null || _ucNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final ucData = {
      'tehsil_id': _selectedTehsilId,
      'name': _ucNameController.text.trim(),
      'created_at': now,
      'updated_at': now,
    };

    if (_editingId == null) {
      await AdminDB.instance.insertRecord('uc', ucData);
    } else {
      ucData['id'] = _editingId;
      await AdminDB.instance.updateRecord('uc', ucData);
    }

    _clearForm();
    _loadUcs();
  }

  void _editUc(Map<String, dynamic> uc) {
    setState(() {
      _editingId = uc['id'] as int?;
      _selectedTehsilId = uc['tehsil_id'] as int?;
      _ucNameController.text = uc['name'] ?? '';
    });
  }

  void _deleteUcWithDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete UC',
        message: 'Are you sure you want to delete this UC?',
        onConfirm: () async {
          await AdminDB.instance.deleteRecord('uc', id);
          _loadUcs();
        },
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedTehsilId = null;
      _ucNameController.clear();
    });
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("UC Management"),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 20),
            Expanded(child: _buildUcList()),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM ----------------
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
                  "Add UC",
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
                      child: DropdownButtonFormField<int>(
                        value: _selectedTehsilId,
                        decoration: const InputDecoration(
                          labelText: "Select Tehsil",
                          border: OutlineInputBorder(),
                        ),
                        items: _tehsilList.map((tehsil) {
                          return DropdownMenuItem<int>(
                            value: tehsil['id'] as int,
                            child: Text(tehsil['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedTehsilId = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _textField(_ucNameController, 'UC Name')),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _saveUc,
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

  // ---------------- TABLE ----------------
  Widget _buildUcList() {
    if (_ucList.isEmpty) {
      return const Center(child: Text('No UCs available.'));
    }

    List<Map<String, dynamic>> _paginated() {
      final start = _currentPage * rowsPerPage;
      final end = start + rowsPerPage;
      return _ucList.sublist(
        start,
        end > _ucList.length ? _ucList.length : end,
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text("Actions")),
                  DataColumn(label: Text("S No.")),
                  DataColumn(label: Text("Tehsil")),
                  DataColumn(label: Text("UC Name")),
                  DataColumn(label: Text("Created At")),
                  DataColumn(label: Text("Updated At")),
                ],
                rows: _paginated().asMap().entries.map((entry) {
                  final index = entry.key;
                  final uc = entry.value;
                  final seqNo = _currentPage * rowsPerPage + index + 1;

                  // Find Tehsil name
                  final tehsilName =
                      _tehsilList.firstWhere(
                        (t) => t['id'] == uc['tehsil_id'],
                        orElse: () => {'name': 'Unknown'},
                      )['name'] ??
                      'Unknown';

                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editUc(uc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteUcWithDialog(uc['id'] as int),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(seqNo.toString())),
                      DataCell(Text(tehsilName)),
                      DataCell(Text(uc['name'] ?? '')),
                      DataCell(Text(_formatDate(uc['created_at']))),
                      DataCell(Text(_formatDate(uc['updated_at']))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
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
