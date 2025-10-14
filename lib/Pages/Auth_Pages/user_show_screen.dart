import 'package:flutter/material.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/components/toast_message.dart';

import '../../model/user_model.dart';
import '../../sqlite/user_create_db_helper.dart';
import '../Auth_Pages/user_create_login_screen.dart';

class UserShowScreen extends StatefulWidget {
  const UserShowScreen({super.key});

  @override
  State<UserShowScreen> createState() => _UserShowScreenState();
}

class _UserShowScreenState extends State<UserShowScreen> {
  List<UserModel> _rows = [];
  List<UserModel> _filteredRows = [];
  final TextEditingController _searchController = TextEditingController();

  final Map<String, String?> _selectedFilters = {'role': null, 'rank': null};
  final Map<String, List<String>> _filterOptions = {};

  bool _sortAscending = true;
  int? _sortColumnIndex;
  int _rowsPerPage = 7;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadUsers() async {
    final data = await UserCreateDbHelper.instance.getUsers();
    final Map<String, List<String>> options = {};

    for (var key in _selectedFilters.keys) {
      final values =
          data
              .map((e) => _valueFor(e, key)?.toString().trim())
              .where((e) => e != null && e.isNotEmpty)
              .toSet()
              .cast<String>()
              .toList()
            ..sort();
      options[key] = values;
    }

    setState(() {
      _rows = data;
      _filterOptions.clear();
      _filterOptions.addAll(options);
      _applyFilters();
    });
  }

  dynamic _valueFor(UserModel user, String key) {
    switch (key) {
      case 'username':
        return user.username;
      case 'phone':
        return user.phone;
      case 'email':
        return user.email;
      case 'role':
        return user.role;
      case 'rank':
        return user.rank;
      case 'date_entry':
        return user.dateEntry;
      default:
        return '';
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredRows = _rows.where((user) {
        bool matchesDropdowns = _selectedFilters.entries.every((entry) {
          final key = entry.key;
          final value = entry.value;
          if (value == null || value.isEmpty) return true;
          final cellValue =
              _valueFor(user, key)?.toString().toLowerCase() ?? '';
          return cellValue == value.toLowerCase();
        });

        final matchesSearch =
            query.isEmpty ||
            [
              user.username,
              user.phone,
              user.email ?? '',
              user.role,
              user.rank ?? '',
              user.province ?? '',
              user.dasb ?? '',
              user.district ?? '',
              user.directorate ?? '',
            ].any((field) => field.toString().toLowerCase().contains(query));

        return matchesDropdowns && matchesSearch;
      }).toList();

      // Reset pagination if filtered set shorter than current page
      if (_currentPage * _rowsPerPage >= _filteredRows.length &&
          _currentPage > 0) {
        _currentPage = 0;
      }
    });
  }

  void _onSort(int columnIndex, String key, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filteredRows.sort((a, b) {
        final aValue = _valueFor(a, key)?.toString().toLowerCase() ?? '';
        final bValue = _valueFor(b, key)?.toString().toLowerCase() ?? '';
        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });
    });
  }

  List<UserModel> get _paginatedRows {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (_currentPage + 1) * _rowsPerPage;
    if (_filteredRows.isEmpty) return [];
    return _filteredRows.sublist(
      startIndex,
      endIndex > _filteredRows.length ? _filteredRows.length : endIndex,
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _showEditDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.username);
    final phoneController = TextEditingController(text: user.phone);
    final emailController = TextEditingController(text: user.email ?? '');
    final rankController = TextEditingController(text: user.rank ?? '');
    final provinceController = TextEditingController(text: user.province ?? '');
    final dasbController = TextEditingController(text: user.dasb ?? '');
    final districtController = TextEditingController(text: user.district ?? '');
    final directorateController = TextEditingController(
      text: user.directorate ?? '',
    );
    final roleController = TextEditingController(text: user.role);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit User"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField("Name", nameController),
                _editField("Phone", phoneController),
                _editField("Email", emailController),
                _editField("Role", roleController),
                _editField("Rank", rankController),
                _editField("Province", provinceController),
                _editField("Dasb", dasbController),
                _editField("District", districtController),
                _editField("Directorate", directorateController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = user.copyWith(
                  username: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text.isEmpty
                      ? null
                      : emailController.text,
                  role: roleController.text,
                  rank: rankController.text,
                  province: provinceController.text,
                  dasb: dasbController.text,
                  district: districtController.text,
                  directorate: directorateController.text,
                  updatedBy: "Admin",
                  updatedAt: DateTime.now().toIso8601String(),
                );
                await UserCreateDbHelper.instance.updateUser(updatedUser);
                ToastMessage.showSuccess(context, "User updated successfully");
                if (mounted) {
                  Navigator.pop(context);
                  _loadUsers();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Users'];

    // Header: all 16 columns
    sheet.appendRow([
      'ID',
      'Name',
      'Phone',
      'Email',
      'Role',
      'Rank',
      'Date Entry',
      'Province',
      'DASB',
      'District',
      'Directorate',
      'Nation Wide Value',
      'Created By',
      'Created At',
      'Updated By',
      'Updated At',
    ]);

    for (var user in _filteredRows) {
      sheet.appendRow([
        user.id ?? '',
        user.username,
        user.phone,
        user.email ?? '',
        user.role,
        user.rank,
        user.dateEntry ?? '',
        user.province ?? '',
        user.dasb ?? '',
        user.district ?? '',
        user.directorate ?? '',
        user.nationWideValue ?? '',
        user.createdBy ?? '',
        user.createdAt ?? '',
        user.updatedBy ?? '',
        user.updatedAt ?? '',
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/users_export.xlsx";
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Excel exported: $filePath")));
    await OpenFilex.open(filePath);
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    final headers = [
      'ID',
      'Name',
      'Phone',
      'Email',
      'Role',
      'Rank',
      'Date Entry',
      'Province',
      'DASB',
      'District',
      'Directorate',
      'NationWide',
      'Created By',
      'Created At',
      'Updated By',
      'Updated At',
    ];

    final data = _filteredRows.map((u) {
      return [
        u.id?.toString() ?? '',
        u.username,
        u.phone,
        u.email ?? '',
        u.role,
        u.rank ?? '',
        u.dateEntry ?? '',
        u.province ?? '',
        u.dasb ?? '',
        u.district ?? '',
        u.directorate ?? '',
        u.nationWideValue ?? '',
        u.createdBy ?? '',
        u.createdAt ?? '',
        u.updatedBy ?? '',
        u.updatedAt ?? '',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'List of Users',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8,
            ),
            cellStyle: pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/users_export.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("PDF exported: $filePath")));
    await OpenFilex.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("List of Users"),
        backgroundColor: const Color(0xff27ADF5),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserCreateScreen()),
                ).then((_) => _loadUsers());
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add User",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 40,
                    child: ButtonComponent(
                      buttonColor: Colors.grey,
                      ontap: _exportToPdf,
                      title: 'PDF',
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: ButtonComponent(
                      buttonColor: Colors.grey,
                      ontap: _exportToExcel,
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
                        setState(() {
                          for (var key in _selectedFilters.keys) {
                            _selectedFilters[key] = null;
                          }
                          _searchController.clear();
                          _applyFilters();
                        });
                      },
                      title: 'Clear Filters',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "User Data",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _filteredRows.isEmpty
                    ? const Center(child: Text("No users found"))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _sortAscending,
                              columnSpacing: 20,
                              headingRowColor: MaterialStateProperty.all(
                                Colors.blue.shade50,
                              ),
                              dataRowHeight: 50,
                              columns: [
                                const DataColumn(label: Text("Actions")),
                                const DataColumn(label: Text("S No.")),
                                DataColumn(
                                  label: const Text("Name"),
                                  onSort: (i, asc) =>
                                      _onSort(i, 'username', asc),
                                ),
                                DataColumn(
                                  label: const Text("Phone"),
                                  onSort: (i, asc) => _onSort(i, 'phone', asc),
                                ),
                                DataColumn(
                                  label: const Text("Email"),
                                  onSort: (i, asc) => _onSort(i, 'email', asc),
                                ),
                                DataColumn(
                                  label: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedFilters['role'],
                                      hint: const Text(
                                        "Role",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'All',
                                          child: Text("All"),
                                        ),
                                        ...(_filterOptions['role'] ?? []).map(
                                          (opt) => DropdownMenuItem(
                                            value: opt,
                                            child: Text(opt),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedFilters['role'] =
                                              value == 'All' ? null : value;
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  ),
                                  onSort: (i, asc) => _onSort(i, 'role', asc),
                                ),
                                DataColumn(
                                  label: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedFilters['rank'],
                                      hint: const Text(
                                        "Rank",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'All',
                                          child: Text("All"),
                                        ),
                                        ...(_filterOptions['rank'] ?? []).map(
                                          (opt) => DropdownMenuItem(
                                            value: opt,
                                            child: Text(opt),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedFilters['rank'] =
                                              value == 'All' ? null : value;
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  ),
                                  onSort: (i, asc) => _onSort(i, 'rank', asc),
                                ),
                                const DataColumn(label: Text("Province")),
                                const DataColumn(label: Text("DASB")),
                                const DataColumn(label: Text("District")),
                                const DataColumn(label: Text("Directorate")),
                                const DataColumn(label: Text("Created Date")),
                              ],
                              rows: _paginatedRows.asMap().entries.map((entry) {
                                final localIndex = entry.key;
                                final index =
                                    localIndex +
                                    1 +
                                    (_currentPage * _rowsPerPage);
                                final user = entry.value;
                                final color = localIndex % 2 == 0
                                    ? MaterialStateProperty.all(Colors.white)
                                    : MaterialStateProperty.all(
                                        Colors.grey.shade50,
                                      );

                                return DataRow(
                                  color: color,
                                  cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .lightBlueAccent
                                                  .shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blueAccent,
                                                  size: 18,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () =>
                                                    _showEditDialog(user),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              alignment: Alignment.center,
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                                size: 18,
                                              ),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text(
                                                      "Delete User",
                                                    ),
                                                    content: const Text(
                                                      "Are you sure you want to delete this user?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          "Cancel",
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                            ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          "Delete",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await UserCreateDbHelper
                                                      .instance
                                                      .deleteUser(user.id!);
                                                  ToastMessage.showSuccess(
                                                    context,
                                                    "Deleted successfully",
                                                  );
                                                  _loadUsers();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text("$index")),
                                    DataCell(Text(user.username)),
                                    DataCell(Text(user.phone)),
                                    DataCell(Text(user.email ?? '-')),
                                    DataCell(Text(user.role)),
                                    DataCell(Text(user.rank ?? '-')),
                                    DataCell(Text(user.province ?? '-')),
                                    DataCell(Text(user.dasb ?? '-')),
                                    DataCell(Text(user.district ?? '-')),
                                    DataCell(Text(user.directorate ?? '-')),
                                    DataCell(Text(_formatDate(user.createdAt))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
              ),

              // Pagination Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("Rows per page: "),
                      DropdownButton<int>(
                        value: _rowsPerPage,
                        items: [2, 5, 7, 10, 20]
                            .map(
                              (num) => DropdownMenuItem(
                                value: num,
                                child: Text("$num"),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _rowsPerPage = value!;
                            _currentPage = 0;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                      ),
                      Text(
                        "Page ${_currentPage + 1} of ${(_filteredRows.length / _rowsPerPage).ceil()}",
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed:
                            (_currentPage + 1) * _rowsPerPage <
                                _filteredRows.length
                            ? () => setState(() => _currentPage++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
