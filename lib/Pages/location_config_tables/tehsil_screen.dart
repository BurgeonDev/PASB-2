import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testing_window_app/components/delete_dialog.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class TehsilScreen extends StatefulWidget {
  const TehsilScreen({super.key});

  @override
  State<TehsilScreen> createState() => _TehsilScreenState();
}

class _TehsilScreenState extends State<TehsilScreen> {
  final TextEditingController _tehsilNameController = TextEditingController();
  int? _selectedDistrictId;
  int? _editingId;

  List<Map<String, dynamic>> _districtList = [];
  List<Map<String, dynamic>> _tehsilList = [];

  int _currentPage = 0;
  final int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
    _loadTehsils();
  }

  Future<void> _loadDistricts() async {
    final data = await AdminDB.instance.fetchAll('district');
    setState(() => _districtList = data);
  }

  Future<void> _loadTehsils() async {
    final data = await AdminDB.instance.fetchAll('tehsil');
    setState(() => _tehsilList = data);
  }

  Future<void> _saveTehsil() async {
    if (_selectedDistrictId == null ||
        _tehsilNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final tehsilData = {
      'district_id': _selectedDistrictId,
      'name': _tehsilNameController.text.trim(),
      'created_at': now,
      'updated_at': now,
    };

    if (_editingId == null) {
      await AdminDB.instance.insertRecord('tehsil', tehsilData);
    } else {
      tehsilData['id'] = _editingId;
      await AdminDB.instance.updateRecord('tehsil', tehsilData);
    }

    _clearForm();
    _loadTehsils();
  }

  void _editTehsil(Map<String, dynamic> tehsil) {
    setState(() {
      _editingId = tehsil['id'] as int?;
      _selectedDistrictId = tehsil['district_id'] as int?;
      _tehsilNameController.text = tehsil['name'] ?? '';
    });
  }

  void _deleteTehsilWithDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete Tehsil',
        message: 'Are you sure you want to delete this Tehsil?',
        onConfirm: () async {
          await AdminDB.instance.deleteRecord('tehsil', id);
          _loadTehsils();
        },
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedDistrictId = null;
      _tehsilNameController.clear();
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
        title: const Text("Tehsil Management"),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 20),
            Expanded(child: _buildTehsilList()),
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
                  "Add Tehsil",
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
                        value: _selectedDistrictId,
                        decoration: const InputDecoration(
                          labelText: "Select District",
                          border: OutlineInputBorder(),
                        ),
                        items: _districtList.map((district) {
                          return DropdownMenuItem<int>(
                            value: district['id'] as int,
                            child: Text(district['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDistrictId = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _textField(_tehsilNameController, 'Tehsil Name'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _saveTehsil,
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
  Widget _buildTehsilList() {
    if (_tehsilList.isEmpty) {
      return const Center(child: Text('No Tehsils available.'));
    }

    List<Map<String, dynamic>> _paginated() {
      final start = _currentPage * rowsPerPage;
      final end = start + rowsPerPage;
      return _tehsilList.sublist(
        start,
        end > _tehsilList.length ? _tehsilList.length : end,
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
                  DataColumn(label: Text("District")),
                  DataColumn(label: Text("Tehsil Name")),
                  DataColumn(label: Text("Created At")),
                  DataColumn(label: Text("Updated At")),
                ],
                rows: _paginated().asMap().entries.map((entry) {
                  final index = entry.key;
                  final tehsil = entry.value;
                  final seqNo = _currentPage * rowsPerPage + index + 1;

                  // Find district name
                  final districtName =
                      _districtList.firstWhere(
                        (d) => d['id'] == tehsil['district_id'],
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
                              onPressed: () => _editTehsil(tehsil),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteTehsilWithDialog(tehsil['id'] as int),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(seqNo.toString())),
                      DataCell(Text(districtName)),
                      DataCell(Text(tehsil['name'] ?? '')),
                      DataCell(Text(_formatDate(tehsil['created_at']))),
                      DataCell(Text(_formatDate(tehsil['updated_at']))),
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
