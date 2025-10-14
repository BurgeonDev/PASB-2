import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  List<Map<String, dynamic>> _bankList = [];
  int? _editingId;

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
      'created_by': 'System', // handled internally
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

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 20),
            Expanded(child: _buildBankList()),
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

  // ---------------- TABLE ----------------
  Widget _buildBankList() {
    if (_bankList.isEmpty) {
      return const Center(child: Text('No banks available.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width, // 👈 full width
        child: DataTable(
          columnSpacing: 25,
          headingRowColor: MaterialStateProperty.all(const Color(0xffe8f4fd)),
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
          rows: _bankList.map((bank) {
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
