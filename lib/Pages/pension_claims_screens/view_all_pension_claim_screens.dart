import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/viewmodel/admin_db_for_tables/admin_db.dart';

import '../../sqlite/pansion_claims_db.dart';

class ViewAllPensionClaimScreens extends StatefulWidget {
  const ViewAllPensionClaimScreens({super.key});

  @override
  State<ViewAllPensionClaimScreens> createState() =>
      _ViewAllPensionClaimScreensState();
}

class _ViewAllPensionClaimScreensState
    extends State<ViewAllPensionClaimScreens> {
  List<Map<String, dynamic>> _claims = [];
  List<Map<String, dynamic>> _filteredClaims = [];
  final TextEditingController _searchController = TextEditingController();

  int _rowsPerPage = 7;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isLoading = true;

  String? _selectedToPerson;
  String? _selectedRelation;

  final List<Map<String, String>> _fields = [
    {'label': 'From', 'key': 'fromPerson'},
    {'label': 'To', 'key': 'toPerson'},
    {'label': 'Pension ID', 'key': 'pensionId'},
    {'label': 'Pension Number', 'key': 'pensionNumber'},
    {'label': 'Claimant', 'key': 'claimant'},
    {'label': 'Relation', 'key': 'relation'},
    {'label': 'Date', 'key': 'date'},
    {'label': 'Message', 'key': 'message'},
    {'label': 'Uploaded File', 'key': 'uploadedFileName'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchClaims();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _fetchClaims() async {
    final data = await AdminDB.instance.fetchAll('pension_claims');
    setState(() {
      _claims = data;
      _filteredClaims = data;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredClaims = _claims.where((claim) {
        final matchesSearch = _fields.any((f) {
          final val = claim[f['key']]?.toString().toLowerCase() ?? '';
          return val.contains(query);
        });

        final matchesTo =
            _selectedToPerson == null || claim['toPerson'] == _selectedToPerson;
        final matchesRelation =
            _selectedRelation == null || claim['relation'] == _selectedRelation;

        return matchesSearch && matchesTo && matchesRelation;
      }).toList();
    });
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['PensionClaims'];

      sheet.appendRow(_fields.map((f) => f['label']).toList());

      for (var claim in _filteredClaims) {
        sheet.appendRow(_fields.map((f) => claim[f['key']] ?? '').toList());
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/pension_claims.xlsx";
      final bytes = excel.encode();
      await File(path).writeAsBytes(bytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Excel exported successfully: $path")),
      );

      await OpenFilex.open(path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to export Excel: $e")));
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => [
            pw.Center(
              child: pw.Text(
                "All Pension Claims",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: _fields.map((f) => f['label']).toList(),
              data: _filteredClaims.map((row) {
                return _fields.map((f) => row[f['key']] ?? '').toList();
              }).toList(),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/pension_claims.pdf";
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF exported successfully: $path")),
      );

      await OpenFilex.open(path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to export PDF: $e")));
    }
  }

  void _onSort(int columnIndex, String key, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _filteredClaims.sort((a, b) {
        final aVal = a[key];
        final bVal = b[key];

        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return ascending ? -1 : 1;
        if (bVal == null) return ascending ? 1 : -1;

        // Numeric sorting
        if (num.tryParse(aVal.toString()) != null &&
            num.tryParse(bVal.toString()) != null) {
          final aNum = num.parse(aVal.toString());
          final bNum = num.parse(bVal.toString());
          return ascending ? aNum.compareTo(bNum) : bNum.compareTo(aNum);
        }

        // Date sorting
        try {
          final aDate = DateTime.tryParse(aVal.toString());
          final bDate = DateTime.tryParse(bVal.toString());
          if (aDate != null && bDate != null) {
            return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
          }
        } catch (_) {}

        // Default string sort
        return ascending
            ? aVal.toString().toLowerCase().compareTo(
                bVal.toString().toLowerCase(),
              )
            : bVal.toString().toLowerCase().compareTo(
                aVal.toString().toLowerCase(),
              );
      });
    });
  }

  List<Map<String, dynamic>> get _paginatedRows {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (_currentPage + 1) * _rowsPerPage;
    return _filteredClaims.sublist(
      startIndex,
      endIndex > _filteredClaims.length ? _filteredClaims.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("All Pension Claims"),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
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
                            ontap: () {
                              _exportToPdf();
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
                              _exportToExcel();
                              print('object');
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
                              setState(() {
                                _selectedToPerson = null;
                                _selectedRelation = null;
                                _searchController.clear();
                                _applyFilters();
                              });
                            },
                            title: 'Clear Filters',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pension Claims",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 250,
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

                    const SizedBox(height: 12),
                    Expanded(
                      child: _filteredClaims.isEmpty
                          ? const Center(
                              child: Text("No pension claims found."),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  columnSpacing: 12,
                                  columns: [
                                    const DataColumn(
                                      label: Text(
                                        "Action",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ..._fields.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final key = entry.value['key']!;
                                      final label = entry.value['label']!;

                                      // Check if this is the "To" or "Relation" column
                                      if (key == 'toPerson') {
                                        return DataColumn(
                                          label: DropdownButton<String>(
                                            value: _selectedToPerson,
                                            hint: Text(
                                              label,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            items: [
                                              const DropdownMenuItem(
                                                value: null,
                                                child: Text("To"),
                                              ),
                                              ..._claims
                                                  .map(
                                                    (e) => e['toPerson']
                                                        ?.toString(),
                                                  )
                                                  .where(
                                                    (e) =>
                                                        e != null &&
                                                        e.isNotEmpty,
                                                  )
                                                  .toSet()
                                                  .map(
                                                    (val) => DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val!),
                                                    ),
                                                  )
                                                  .toList(),
                                            ],
                                            onChanged: (val) {
                                              setState(() {
                                                _selectedToPerson = val;
                                                _applyFilters();
                                              });
                                            },
                                          ),
                                        );
                                      } else if (key == 'relation') {
                                        return DataColumn(
                                          label: DropdownButton<String>(
                                            value: _selectedRelation,
                                            hint: Text(
                                              label,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            items: [
                                              const DropdownMenuItem(
                                                value: null,
                                                child: Text("Relation"),
                                              ),
                                              ..._claims
                                                  .map(
                                                    (e) => e['relation']
                                                        ?.toString(),
                                                  )
                                                  .where(
                                                    (e) =>
                                                        e != null &&
                                                        e.isNotEmpty,
                                                  )
                                                  .toSet()
                                                  .map(
                                                    (val) => DropdownMenuItem(
                                                      value: val,
                                                      child: Text(val!),
                                                    ),
                                                  )
                                                  .toList(),
                                            ],
                                            onChanged: (val) {
                                              setState(() {
                                                _selectedRelation = val;
                                                _applyFilters();
                                              });
                                            },
                                          ),
                                        );
                                      } else {
                                        return DataColumn(
                                          label: Text(
                                            label,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onSort: (colIndex, ascending) {
                                            _onSort(colIndex, key, ascending);
                                          },
                                        );
                                      }
                                    }).toList(),
                                  ],
                                  rows: _paginatedRows.asMap().entries.map((e) {
                                    final idx = e.key;
                                    final claim = e.value;
                                    final color = idx % 2 == 0
                                        ? MaterialStateProperty.all(
                                            Colors.white,
                                          )
                                        : MaterialStateProperty.all(
                                            Colors.grey.shade50,
                                          );

                                    return DataRow(
                                      color: color,
                                      cells: [
                                        // Action buttons
                                        DataCell(
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Viewing claim of ${claim['claimant']}',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  textStyle: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'View',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              ElevatedButton(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Replying to ${claim['claimant']}',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  textStyle: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Reply',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Existing columns
                                        ..._fields.map((f) {
                                          final key = f['key']!;
                                          if (key == 'uploadedFileName') {
                                            final fileName =
                                                claim['uploadedFileName'] ?? '';
                                            final filePath =
                                                claim['uploadedFilePath'] ?? '';

                                            return DataCell(
                                              InkWell(
                                                onTap: () async {
                                                  if (filePath.isNotEmpty) {
                                                    print(
                                                      'Opening file: $filePath',
                                                    );
                                                    final result =
                                                        await OpenFilex.open(
                                                          filePath,
                                                        );
                                                    print(
                                                      'Result: ${result.message}',
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'No file path available.',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  filePath ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return DataCell(
                                              Text(
                                                claim[key]?.toString() ?? '',
                                              ),
                                            );
                                          }
                                        }).toList(),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                    ),
                    // Pagination footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("Rows per page: "),
                              DropdownButton<int>(
                                value: _rowsPerPage,
                                items: [5, 7, 10, 20]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text("$e"),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _rowsPerPage = val!;
                                    _currentPage = 0;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 18,
                                ),
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                              ),
                              Text(
                                "Page ${_currentPage + 1} of ${(_filteredClaims.length / _rowsPerPage).ceil()}",
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                ),
                                onPressed:
                                    (_currentPage + 1) * _rowsPerPage <
                                        _filteredClaims.length
                                    ? () => setState(() => _currentPage++)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
