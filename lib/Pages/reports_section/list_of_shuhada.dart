import 'package:flutter/material.dart';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/sqlite/user_database_helper.dart';

class ListOfShuhada extends StatefulWidget {
  const ListOfShuhada({super.key});
  @override
  State<ListOfShuhada> createState() => _ListOfShuhadaState();
}

class _ListOfShuhadaState extends State<ListOfShuhada> {
  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _filteredRows = [];
  final TextEditingController _searchController = TextEditingController();

  // Filters
  final Map<String, String?> _selectedFilters = {
    'rank': null,
    'trade': null,
    'regt': null,
    'med_cat': null,
    'character': null,
    'cause_disch': null,
    'type_of_pension': null,
    'dasb': null,
    'source_verification': null,
    'tehsil': null,
    'district': null,
    'war_ops': null,
  };

  final Map<String, List<String>> _filterOptions = {};

  final List<Map<String, String>> _fields = [
    {'label': 'S No.', 'key': 'id'},
    {'label': 'Date Entry', 'key': 'date_entry'},
    {'label': 'Prefix', 'key': 'prefix'},
    {'label': 'Personal No', 'key': 'personal_no'},
    {'label': 'Rank', 'key': 'rank'},
    {'label': 'Trade', 'key': 'trade'},
    {'label': 'Name', 'key': 'name'},
    {'label': 'Regt/Corps', 'key': 'regt'},
    {'label': 'Parent Unit', 'key': 'parent_unit'},
    {'label': 'Father Name', 'key': 'father_name'},
    {'label': 'DOB', 'key': 'dob'},
    {'label': 'DO Enlist', 'key': 'do_enlt'},
    {'label': 'DO Discharge', 'key': 'do_disch'},
    {'label': 'Honours', 'key': 'honours'},
    {'label': 'Civil Edn', 'key': 'civil_edn'},
    {'label': 'Med Cat', 'key': 'med_cat'},
    {'label': 'Character', 'key': 'character'},
    {'label': 'Cause Disch', 'key': 'cause_disch'},
    {'label': 'Village', 'key': 'village'},
    {'label': 'Post Office', 'key': 'post_office'},
    {'label': 'UC Name', 'key': 'uc_name'},
    {'label': 'Tehsil', 'key': 'tehsil'},
    {'label': 'District', 'key': 'district'},
    {'label': 'Present Addr', 'key': 'present_addr'},
    {'label': 'CNIC', 'key': 'cnic'},
    {'label': 'Mobile', 'key': 'mobile'},
    {'label': 'NOK Name', 'key': 'nok_name'},
    {'label': 'NOK Relation', 'key': 'nok_relation'},
    {'label': 'NOK CNIC', 'key': 'nok_cnic'},
    {'label': 'Type of Pension', 'key': 'type_of_pension'},
    {'label': 'DO Death', 'key': 'do_death'},
    {'label': 'Place Death', 'key': 'place_death'},
    {'label': 'Cause Death', 'key': 'cause_death'},
    {'label': 'War/Ops', 'key': 'war_ops'},
    {'label': 'Location Graveyard', 'key': 'loc_graveyard'},
    {'label': 'DO Disability', 'key': 'do_disability'},
    {'label': 'Nature Disability', 'key': 'nature_disability'},
    {'label': 'CL Disability', 'key': 'cl_disability'},
    {'label': 'Remarks', 'key': 'gen_remarks'},
    {'label': 'DASB', 'key': 'dasb'},
    {'label': 'Source Verification', 'key': 'source_verification'},
    {'label': 'DO Verification', 'key': 'do_verification'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  // Future<void> _showExportDialog() async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Export Options"),
  //         content: const Text("Choose a format to export filtered data."),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _exportToExcel();
  //             },
  //             child: const Text("Export to Excel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _exportToPdf();
  //             },
  //             child: const Text("Export to PDF"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Shuhada'];

      // Header row
      sheet.appendRow(_fields.map((f) => f['label']).toList());

      // Data rows (filtered rows)
      for (var row in _filteredRows) {
        sheet.appendRow(
          _fields.map((f) {
            final val = _valueFor(row, f['key']!);
            return val ?? '';
          }).toList(),
        );
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/shuhada_export.xlsx";
      final fileBytes = excel.encode();
      final file = File(filePath);
      await file.writeAsBytes(fileBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Excel exported successfully: $filePath")),
      );

      // 👇 Automatically open the Excel file
      await OpenFilex.open(filePath);
    } catch (e) {
      debugPrint("Error exporting Excel: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to export Excel")));
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) {
            return [
              pw.Center(
                child: pw.Text(
                  "List of Shuhada",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: _fields.map((f) => f['label']).toList(),
                data: _filteredRows.map((row) {
                  return _fields.map((f) {
                    final val = _valueFor(row, f['key']!);
                    return val ?? '';
                  }).toList();
                }).toList(),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 8),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/shuhada_export.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF exported successfully: $filePath")),
      );

      // 👇 Automatically open the PDF file
      await OpenFilex.open(filePath);

      // Optional: open or share the PDF
      // await Printing.sharePdf(
      //     bytes: await pdf.save(), filename: 'shuhada_export.pdf');
    } catch (e) {
      debugPrint("Error exporting PDF: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to export PDF")));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final shuhada = await DatabaseHelper2.instance.getShuhada();

      final Map<String, List<String>> options = {};
      for (var key in _selectedFilters.keys) {
        final values =
            shuhada
                .map((e) => e[key]?.toString().trim())
                .where((e) => e != null && e.isNotEmpty)
                .toSet()
                .cast<String>()
                .toList()
              ..sort();
        options[key] = values;
      }

      setState(() {
        _rows = shuhada;
        _filterOptions.clear();
        _filterOptions.addAll(options);
        _applyFilters();
      });
    } catch (e) {
      debugPrint("Error loading Shuhada data: $e");
    }
  }

  Future<void> _deleteRow(int id) async {
    await DatabaseHelper2.instance.delete(id);
    await _loadData();
  }

  dynamic _valueFor(Map<String, dynamic> row, String key) {
    if (row.containsKey(key)) return _cleanValue(row[key]);
    for (final k in row.keys) {
      if (k.toString().toLowerCase() == key.toLowerCase()) {
        return _cleanValue(row[k]);
      }
    }
    return null;
  }

  String _cleanValue(dynamic value) {
    if (value == null) return '-';
    String str = value.toString();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(str)) {
      str = str.substring(0, 10);
      try {
        final date = DateTime.parse(str);
        return "${date.day.toString().padLeft(2, '0')}-${_monthName(date.month)}-${date.year}";
      } catch (_) {
        return str;
      }
    }
    return str;
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredRows = _rows.where((row) {
        // Dropdown filters
        bool matchesDropdowns = _selectedFilters.entries.every((entry) {
          final key = entry.key;
          final value = entry.value;
          if (value == null || value.isEmpty) return true;
          final cellValue = row[key]?.toString().toLowerCase() ?? '';
          return cellValue == value.toLowerCase();
        });

        // Search filter
        final matchesSearch =
            query.isEmpty ||
            _fields.any((f) {
              final val = _valueFor(row, f['key']!);
              return val != null &&
                  val.toString().toLowerCase().contains(query);
            });

        return matchesDropdowns && matchesSearch;
      }).toList();
    });
  }

  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _onSort(int columnIndex, String key, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      // Handle special cases for sorting
      if (key == 'id') {
        // For S No. column, sort by database ID (which represents the order)
        _filteredRows.sort((a, b) {
          final aId = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
          final bId = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
          return ascending ? aId.compareTo(bId) : bId.compareTo(aId);
        });
      } else if (key == 'date_entry') {
        // For Date Entry, parse dates properly
        _filteredRows.sort((a, b) {
          final aDate = _parseDate(a[key]?.toString() ?? '');
          final bDate = _parseDate(b[key]?.toString() ?? '');
          return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        });
      } else {
        // For other columns, use string comparison
        _filteredRows.sort((a, b) {
          final aValue = _valueFor(a, key)?.toString().toLowerCase() ?? '';
          final bValue = _valueFor(b, key)?.toString().toLowerCase() ?? '';
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        });
      }
    });
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty) return DateTime(1900);

    // Handle different date formats
    try {
      // Try parsing YYYY-MM-DD format
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(dateStr)) {
        return DateTime.parse(dateStr);
      }

      // Try parsing DD-MM-YYYY format
      if (RegExp(r'^\d{2}-\d{2}-\d{4}').hasMatch(dateStr)) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }

      // Try parsing DD-MMM-YYYY format (like 01-Jan-2023)
      if (RegExp(r'^\d{2}-[A-Za-z]{3}-\d{4}').hasMatch(dateStr)) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final monthMap = {
            'Jan': 1,
            'Feb': 2,
            'Mar': 3,
            'Apr': 4,
            'May': 5,
            'Jun': 6,
            'Jul': 7,
            'Aug': 8,
            'Sep': 9,
            'Oct': 10,
            'Nov': 11,
            'Dec': 12,
          };
          final month = monthMap[parts[1]] ?? 1;
          return DateTime(int.parse(parts[2]), month, int.parse(parts[0]));
        }
      }

      return DateTime(1900);
    } catch (e) {
      return DateTime(1900);
    }
  }

  // Pagination variables
  int _rowsPerPage = 7;
  int _currentPage = 0;

  // Helper method to get paginated data
  List<Map<String, dynamic>> get _paginatedRows {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (_currentPage + 1) * _rowsPerPage;
    return _filteredRows.sublist(
      startIndex,
      endIndex > _filteredRows.length ? _filteredRows.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("List of Shuhada"),
        backgroundColor: Color(0xff27ADF5),
        actions: [
          Row(
            children: [
              // GestureDetector(
              //   onTap: _showExportDialog,
              //   child: Container(
              //     decoration: BoxDecoration(
              //         color: Colors.lightBlueAccent,
              //         borderRadius: BorderRadius.circular(8)),
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Text('Export'),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Add Pensioner',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
            ],
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
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
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
                  SizedBox(width: 10),
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
                  SizedBox(width: 10),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Shuhada Data",
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
              const SizedBox(height: 12),
              Expanded(
                child: _filteredRows.isEmpty
                    ? const Center(child: Text("No matching records found."))
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
                                  "Actions",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ..._fields.asMap().entries.map((entry) {
                                final index = entry.key;
                                final f = entry.value;
                                final key = f['key']!;
                                final label = f['label']!;

                                if (_selectedFilters.containsKey(key)) {
                                  final options =
                                      _filterOptions[key] ?? <String>[];
                                  return DataColumn(
                                    label: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedFilters[key],
                                        hint: Text(
                                          label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: 'All',
                                            child: Text("All"),
                                          ),
                                          ...options.map(
                                            (opt) => DropdownMenuItem<String>(
                                              value: opt,
                                              child: Text(opt),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == 'All') {
                                              _selectedFilters[key] = null;
                                            } else {
                                              _selectedFilters[key] = value;
                                            }
                                            _applyFilters();
                                          });
                                        },
                                      ),
                                    ),
                                    onSort: (columnIndex, ascending) {
                                      _onSort(columnIndex, key, ascending);
                                    },
                                  );
                                } else {
                                  return DataColumn(
                                    label: Text(
                                      label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onSort: (columnIndex, ascending) {
                                      _onSort(columnIndex, key, ascending);
                                    },
                                  );
                                }
                              }).toList(),
                            ],
                            // ✅ Use paginated rows instead of full filtered list
                            rows: _paginatedRows.asMap().entries.map((entry) {
                              final index = entry.key;
                              final row = entry.value;
                              final id = _valueFor(row, 'id')?.toString() ?? '';

                              // Calculate sequential S No. starting from 1
                              final sequentialNumber =
                                  (_currentPage * _rowsPerPage) + index + 1;

                              final actionCell = DataCell(
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlueAccent.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blueAccent,
                                            size: 18,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            // TODO: edit functionality
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(6),
                                        onTap: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                "Delete Record",
                                              ),
                                              content: const Text(
                                                "Are you sure you want to delete this record?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            final idInt = int.tryParse(id) ?? 0;
                                            if (idInt > 0) {
                                              await _deleteRow(idInt);
                                            }
                                          }
                                        },
                                        child: const Center(
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              final dataCells = _fields.asMap().entries.map((
                                fieldEntry,
                              ) {
                                final fieldIndex = fieldEntry.key;
                                final f = fieldEntry.value;

                                // For the first field (S No.), use sequential number
                                if (fieldIndex == 0) {
                                  return DataCell(
                                    Text(sequentialNumber.toString()),
                                  );
                                }

                                // For other fields, use the original logic
                                final val = _valueFor(row, f['key']!);
                                return DataCell(Text(val?.toString() ?? '-'));
                              }).toList();

                              // 👇 Alternate row colors (even = white, odd = light grey)
                              final color = index % 2 == 0
                                  ? MaterialStateProperty.all(Colors.white)
                                  : MaterialStateProperty.all(
                                      Colors.grey.shade50,
                                    );

                              return DataRow(
                                color: color,
                                cells: [actionCell, ...dataCells],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rows per page dropdown
                    Row(
                      children: [
                        const Text("Rows per page: "),
                        DropdownButton<int>(
                          value: _rowsPerPage,
                          items: [2, 5, 7, 10, 20]
                              .map(
                                (num) => DropdownMenuItem<int>(
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

                    // Page navigation
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
