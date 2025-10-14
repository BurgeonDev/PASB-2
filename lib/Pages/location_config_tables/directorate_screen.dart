import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  List<Map<String, dynamic>> _directorateList = [];
  List<Map<String, dynamic>> _provinceList = [];

  int? _selectedProvinceId;
  int? _editingId;

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
      'created_by': _createdByController.text.trim(),
      'created_at': now,
      'updated_by': _createdByController.text.trim(),
      'updated_at': now,
    };

    if (_editingId == null) {
      await AdminDB.instance.insertRecord('directorate', directorateData);
    } else {
      // Update logic can be added later if required
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

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 20),
            Expanded(child: _buildDirectorateList()),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM ----------------
  Widget _buildForm() {
    return Center(
      child: SizedBox(
        width: 700,
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
                  "Add Directorate",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Flexible(flex: 2, child: _buildProvinceDropdown()),
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
      onChanged: (value) {
        setState(() {
          _selectedProvinceId = value;
        });
      },
    );
  }

  // ---------------- TABLE ----------------
  Widget _buildDirectorateList() {
    if (_directorateList.isEmpty) {
      return const Center(child: Text('No directorates available.'));
    }

    final int rowsPerPage = 10;
    int _currentPage = 0;

    List<Map<String, dynamic>> _paginated() {
      final start = _currentPage * rowsPerPage;
      final end = start + rowsPerPage;
      return _directorateList.sublist(
        start,
        end > _directorateList.length ? _directorateList.length : end,
      );
    }

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text("Actions")),
                      DataColumn(label: Text("S No.")),
                      DataColumn(label: Text("Province")),
                      DataColumn(label: Text("Directorate Name")),
                      DataColumn(label: Text("Created By")),
                      DataColumn(label: Text("Created At")),
                      DataColumn(label: Text("Updated By")),
                      DataColumn(label: Text("Updated At")),
                    ],
                    rows: _paginated().asMap().entries.map((entry) {
                      final index = entry.key;
                      final dir = entry.value;
                      final seqNo = _currentPage * rowsPerPage + index + 1;

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editDirectorate(dir),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteDirectorateWithDialog(
                                    dir['id'] as int,
                                  ),
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
