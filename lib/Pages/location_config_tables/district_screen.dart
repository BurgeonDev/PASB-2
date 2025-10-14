import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testing_window_app/components/delete_dialog.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

class DistrictScreen extends StatefulWidget {
  const DistrictScreen({super.key});

  @override
  State<DistrictScreen> createState() => _DistrictScreenState();
}

class _DistrictScreenState extends State<DistrictScreen> {
  final TextEditingController _districtNameController = TextEditingController();
  final TextEditingController _createdByController = TextEditingController();

  List<Map<String, dynamic>> _districtList = [];
  List<Map<String, dynamic>> _provinceList = [];
  List<Map<String, dynamic>> _directorateList = [];
  List<Map<String, dynamic>> _dasbList = [];

  int? _selectedProvinceId;
  int? _selectedDirectorateId;
  int? _selectedDasbId;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _loadDistricts();
  }

  // ✅ Convert results to modifiable lists
  Future<void> _loadProvinces() async {
    final provinces = await AdminDB.instance.fetchAll('province');
    setState(() => _provinceList = List<Map<String, dynamic>>.from(provinces));
  }

  Future<void> _loadDirectorates(int provinceId) async {
    final dirs = await AdminDB.instance.fetchWhere(
      'directorate',
      'province_id = ?',
      [provinceId],
    );
    setState(() => _directorateList = List<Map<String, dynamic>>.from(dirs));
  }

  Future<void> _loadDasb(int directorateId) async {
    final dasbs = await AdminDB.instance.fetchWhere(
      'dasb',
      'directorate_id = ?',
      [directorateId],
    );
    setState(() => _dasbList = List<Map<String, dynamic>>.from(dasbs));
  }

  Future<void> _loadDistricts() async {
    final data = await AdminDB.instance.fetchAll('district');
    setState(() => _districtList = List<Map<String, dynamic>>.from(data));
  }

  Future<void> _saveDistrict() async {
    if (_selectedProvinceId == null ||
        _selectedDirectorateId == null ||
        _selectedDasbId == null ||
        _districtNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final districtData = {
      'dasb_id': _selectedDasbId,
      'name': _districtNameController.text.trim(),
      'created_by': _createdByController.text.trim(),
      'created_at': now,
      'updated_by': _createdByController.text.trim(),
      'updated_at': now,
    };

    if (_editingId == null) {
      await AdminDB.instance.insertRecord('district', districtData);
    } else {
      //s await AdminDB.instance.updateRecord('district', _editingId!, districtData);
    }

    _clearForm();
    _loadDistricts();
  }

  void _editDistrict(Map<String, dynamic> district) async {
    setState(() {
      _editingId = district['id'];
      _districtNameController.text = district['name'] ?? '';
      _createdByController.text = district['created_by'] ?? '';
    });

    final dasbId = district['dasb_id'] is int
        ? district['dasb_id']
        : int.tryParse(district['dasb_id'].toString());

    final dasb = await AdminDB.instance.fetchWhere('dasb', 'id = ?', [dasbId]);
    if (dasb.isNotEmpty) {
      final directorateId = dasb.first['directorate_id'];
      final directorate = await AdminDB.instance.fetchWhere(
        'directorate',
        'id = ?',
        [directorateId],
      );
      if (directorate.isNotEmpty) {
        final provinceId = directorate.first['province_id'];
        await _loadDirectorates(provinceId);
        await _loadDasb(directorateId);
        setState(() {
          _selectedProvinceId = provinceId;
          _selectedDirectorateId = directorateId;
          _selectedDasbId = dasbId;
        });
      }
    }
  }

  void _deleteDistrictWithDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete District',
        message: 'Are you sure you want to delete this district?',
        onConfirm: () async {
          await AdminDB.instance.deleteRecord('district', id);
          _loadDistricts();
        },
      ),
    );
  }

  // ✅ Fix clearForm (no .clear() on read-only lists)
  void _clearForm() {
    setState(() {
      _editingId = null;
      _selectedProvinceId = null;
      _selectedDirectorateId = null;
      _selectedDasbId = null;
      _districtNameController.clear();
      _createdByController.clear();
      _directorateList = [];
      _dasbList = [];
    });
  }

  // ✅ Fetch names dynamically from DB instead of _selectedIds
  Future<String> _getProvinceNameFromDistrict(int dasbId) async {
    final dasb = await AdminDB.instance.fetchWhere('dasb', 'id = ?', [dasbId]);
    if (dasb.isEmpty) return '';
    final directorate = await AdminDB.instance.fetchWhere(
      'directorate',
      'id = ?',
      [dasb.first['directorate_id']],
    );
    if (directorate.isEmpty) return '';
    final province = await AdminDB.instance.fetchWhere('province', 'id = ?', [
      directorate.first['province_id'],
    ]);
    if (province.isEmpty) return '';
    return province.first['name'] ?? '';
  }

  Future<String> _getDirectorateNameFromDistrict(int dasbId) async {
    final dasb = await AdminDB.instance.fetchWhere('dasb', 'id = ?', [dasbId]);
    if (dasb.isEmpty) return '';
    final directorate = await AdminDB.instance.fetchWhere(
      'directorate',
      'id = ?',
      [dasb.first['directorate_id']],
    );
    return directorate.isNotEmpty ? directorate.first['name'] ?? '' : '';
  }

  Future<String> _getDasbNameFromDistrict(int dasbId) async {
    final dasb = await AdminDB.instance.fetchWhere('dasb', 'id = ?', [dasbId]);
    return dasb.isNotEmpty ? dasb.first['name'] ?? '' : '';
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
        title: const Text("District Management"),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 20),
            Expanded(child: _buildDistrictList()),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM ----------------
  Widget _buildForm() {
    return Center(
      child: SizedBox(
        width: 1200,
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
                  "Add District",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildProvinceDropdown()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDirectorateDropdown()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDasbDropdown()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _textField(
                        _districtNameController,
                        'District Name',
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _saveDistrict,
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
      onChanged: (value) async {
        setState(() {
          _selectedProvinceId = value;
          _selectedDirectorateId = null;
          _selectedDasbId = null;
          _directorateList = [];
          _dasbList = [];
        });
        if (value != null) await _loadDirectorates(value);
      },
    );
  }

  Widget _buildDirectorateDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedDirectorateId,
      decoration: const InputDecoration(
        labelText: 'Select Directorate',
        border: OutlineInputBorder(),
      ),
      items: _directorateList.map((dir) {
        return DropdownMenuItem<int>(
          value: dir['id'] as int,
          child: Text(dir['name'] ?? ''),
        );
      }).toList(),
      onChanged: (value) async {
        setState(() {
          _selectedDirectorateId = value;
          _selectedDasbId = null;
          _dasbList = [];
        });
        if (value != null) await _loadDasb(value);
      },
    );
  }

  Widget _buildDasbDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedDasbId,
      decoration: const InputDecoration(
        labelText: 'Select DASB',
        border: OutlineInputBorder(),
      ),
      items: _dasbList.map((dasb) {
        return DropdownMenuItem<int>(
          value: dasb['id'] as int,
          child: Text(dasb['name'] ?? ''),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedDasbId = value);
      },
    );
  }

  // ---------------- TABLE ----------------
  Widget _buildDistrictList() {
    if (_districtList.isEmpty) {
      return const Center(child: Text('No districts available.'));
    }

    return FutureBuilder<List<DataRow>>(
      future: _buildDataRows(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text("Actions")),
              DataColumn(label: Text("S No.")),
              DataColumn(label: Text("Province")),
              DataColumn(label: Text("Directorate")),
              DataColumn(label: Text("DASB")),
              DataColumn(label: Text("District Name")),
              DataColumn(label: Text("Created By")),
              DataColumn(label: Text("Created At")),
              DataColumn(label: Text("Updated By")),
              DataColumn(label: Text("Updated At")),
            ],
            rows: rows,
          ),
        );
      },
    );
  }

  Future<List<DataRow>> _buildDataRows() async {
    List<DataRow> rows = [];
    for (var i = 0; i < _districtList.length; i++) {
      final dist = _districtList[i];
      final dasbId = dist['dasb_id'] is int
          ? dist['dasb_id']
          : int.tryParse(dist['dasb_id'].toString()) ?? 0;

      final provinceName = await _getProvinceNameFromDistrict(dasbId);
      final directorateName = await _getDirectorateNameFromDistrict(dasbId);
      final dasbName = await _getDasbNameFromDistrict(dasbId);

      rows.add(
        DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editDistrict(dist),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteDistrictWithDialog(dist['id'] as int),
                  ),
                ],
              ),
            ),
            DataCell(Text((i + 1).toString())),
            DataCell(Text(provinceName)),
            DataCell(Text(directorateName)),
            DataCell(Text(dasbName)),
            DataCell(Text(dist['name'] ?? '')),
            DataCell(Text(dist['created_by'] ?? '')),
            DataCell(Text(_formatDate(dist['created_at']))),
            DataCell(Text(dist['updated_by'] ?? '')),
            DataCell(Text(_formatDate(dist['updated_at']))),
          ],
        ),
      );
    }
    return rows;
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
