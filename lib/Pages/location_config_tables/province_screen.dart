import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  List<Map<String, dynamic>> _provinceList = [];
  int? _editingId;

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
      'created_by': _createdByController.text.trim(),
      'created_at': now,
      'updated_by': _createdByController.text.trim(),
      'updated_at': now,
    };

    if (_editingId == null) {
      await AdminDB.instance.insertRecord('province', provinceData);
    } else {
      // You can add update functionality here if needed later
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
        title: const Text("Province Management"),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 20),
            Expanded(child: _buildProvinceList()),
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

  // ---------------- TABLE ----------------
  Widget _buildProvinceList() {
    if (_provinceList.isEmpty) {
      return const Center(child: Text('No provinces available.'));
    }

    final int rowsPerPage = 10;
    int _currentPage = 0;

    List<Map<String, dynamic>> _paginated() {
      final start = _currentPage * rowsPerPage;
      final end = start + rowsPerPage;
      return _provinceList.sublist(
        start,
        end > _provinceList.length ? _provinceList.length : end,
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
                      DataColumn(label: Text("Province Name")),
                      DataColumn(label: Text("Created By")),
                      DataColumn(label: Text("Created At")),
                      DataColumn(label: Text("Updated By")),
                      DataColumn(label: Text("Updated At")),
                    ],
                    rows: _paginated().asMap().entries.map((entry) {
                      final index = entry.key;
                      final province = entry.value;
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
                                  onPressed: () => _editProvince(province),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteProvinceWithDialog(
                                    province['id'] as int,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(seqNo.toString())),
                          DataCell(Text(province['name'] ?? '')),
                          DataCell(Text(province['created_by'] ?? '')),
                          DataCell(Text(_formatDate(province['created_at']))),
                          DataCell(Text(province['updated_by'] ?? '')),
                          DataCell(Text(_formatDate(province['updated_at']))),
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
