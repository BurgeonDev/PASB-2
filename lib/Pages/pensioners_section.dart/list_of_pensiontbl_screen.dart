import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:testing_window_app/components/button_component.dart';

import 'package:testing_window_app/sqlite/pensiontbll_database_Helper.dart';

class ListOfPensionDataScreen extends StatefulWidget {
  const ListOfPensionDataScreen({super.key});

  @override
  State<ListOfPensionDataScreen> createState() =>
      _ListOfPensionDataScreenState();
}

class _ListOfPensionDataScreenState extends State<ListOfPensionDataScreen> {
  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _filteredRows = [];
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _fields = [
    {'label': 'Pen Ex No', 'key': 'PenExNo'},
    {'label': 'Status', 'key': 'Status'},
    {'label': 'Pen DO Entry', 'key': 'PenDOEntry'},
    {'label': 'Reg Ser No', 'key': 'RegSerNo'},
    {'label': 'GP Insurance Claim Ltr Date', 'key': 'GpInsuranceClaimLtrDate'},
    {'label': 'Ben Fund Claim Ltr No', 'key': 'BenFundClaimLtrNo'},
    {'label': 'Ben Fund Claim Ltr Date', 'key': 'BenFundClaimLtrDate'},
    {'label': 'DASB Ltr No', 'key': 'DASBLtrNo'},
    {'label': 'DASB Ltr Date', 'key': 'DASBLtrDate'},
    {'label': 'Finalized Date', 'key': 'FinalizedDate'},
    {'label': 'Particulars Of HWO', 'key': 'ParticularsOfHWO'},
    {'label': 'Originator', 'key': 'Originator'},
    {'label': 'Originator Ltr No', 'key': 'OriginatorLtrNo'},
    {'label': 'Originator Ltr Date', 'key': 'OriginatorLtrDate'},
    {'label': 'Originator Response', 'key': 'OriginatorResponse'},
    {'label': 'History', 'key': 'History'},
    {'label': 'Pension Case Remarks', 'key': 'PensionCaseRemarks'},
    {'label': 'Verified By', 'key': 'VerifiedBy'},
    {'label': 'First Witness', 'key': 'FirstWitness'},
    {'label': 'Second Witness', 'key': 'SecondWitness'},
    {'label': 'DO Marriage', 'key': 'DOMarriage'},
    {'label': 'Next NOK Name', 'key': 'NextNOKName'},
    {'label': 'Next NOK Relation', 'key': 'NextNOKRelation'},
    {'label': 'Next NOK CNIC No', 'key': 'NextNOKCNICNo'},
    {'label': 'Urdu Name', 'key': 'UrduName'},
    {'label': 'Urdu Father Name', 'key': 'UrduFatherName'},
    {'label': 'Urdu NOK Name', 'key': 'UrduNOKName'},
    {'label': 'Urdu Next NOK Name', 'key': 'UrduNextNOKName'},
    {'label': 'Urdu Next NOK Relation', 'key': 'UrduNextNOKRelation'},
    {'label': 'Urdu Relation', 'key': 'UrduRelation'},
    {'label': 'Urdu Village', 'key': 'UrduVillage'},
    {'label': 'Urdu Post Office', 'key': 'UrduPostOffice'},
    {'label': 'Urdu Teh', 'key': 'UrduTeh'},
    {'label': 'Urdu Distt', 'key': 'UrduDistt'},
    {'label': 'Urdu Present Address', 'key': 'UrduPresentAddress'},
  ];

  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _rowsPerPage = 7;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final data = await PensionDB.instance.getAllPensions();
      setState(() {
        _rows = data;
        _applyFilters();
      });
    } catch (e) {
      debugPrint("Error loading PensionData: $e");
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredRows = _rows.where((row) {
        final matchesSearch =
            query.isEmpty ||
            _fields.any((f) {
              final val = row[f['key']]?.toString() ?? '';
              return val.toLowerCase().contains(query);
            });
        return matchesSearch;
      }).toList();
    });
  }

  Future<void> _deleteRow(int id) async {
    await PensionDB.instance.deletePension(id);
    _loadData();
  }

  dynamic _valueFor(Map<String, dynamic> row, String key) {
    return row[key] ?? '-';
  }

  void _onSort(int columnIndex, String key, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filteredRows.sort((a, b) {
        final aValue = _valueFor(a, key).toString();
        final bValue = _valueFor(b, key).toString();
        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });
    });
  }

  List<Map<String, dynamic>> get _paginatedRows {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (_currentPage + 1) * _rowsPerPage > _filteredRows.length
        ? _filteredRows.length
        : (_currentPage + 1) * _rowsPerPage;
    return _filteredRows.sublist(startIndex, endIndex);
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Pension Data'];
      sheet.appendRow(_fields.map((f) => f['label']).toList());
      for (var row in _filteredRows) {
        sheet.appendRow(_fields.map((f) => row[f['key']] ?? '').toList());
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/pension_data.xlsx");
      await file.writeAsBytes(excel.encode()!);
      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint("Excel export failed: $e");
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
                "Pension Data Records",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: _fields.map((f) => f['label']).toList(),
              data: _filteredRows
                  .map(
                    (row) => _fields.map((f) => row[f['key']] ?? '').toList(),
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
              ),
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/pension_data.pdf");
      await file.writeAsBytes(await pdf.save());
      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint("PDF export failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("Pension Data List"),
        backgroundColor: const Color(0xff27ADF5),
        actions: [
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
                      _searchController.clear();
                      _applyFilters();
                    });
                  },
                  title: 'Clear Filters',
                ),
              ),
              const SizedBox(width: 12),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pension Data Records",
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
                            columns: [
                              const DataColumn(label: Text("Actions")),
                              const DataColumn(label: Text("S. No.")),
                              ..._fields.asMap().entries.map((entry) {
                                final f = entry.value;
                                return DataColumn(
                                  label: Text(
                                    f['label']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    _onSort(columnIndex, f['key']!, ascending);
                                  },
                                );
                              }).toList(),
                            ],
                            rows: _paginatedRows.asMap().entries.map((entry) {
                              final index = entry.key;
                              final row = entry.value;
                              final id = row['FPID']?.toString() ?? '';

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
                                            // TODO: Navigate to Pension edit screen
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
                                            if (idInt > 0)
                                              await _deleteRow(idInt);
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

                              final dataCells = _fields
                                  .map(
                                    (f) => DataCell(
                                      Text(
                                        _valueFor(row, f['key']!).toString(),
                                      ),
                                    ),
                                  )
                                  .toList();

                              return DataRow(
                                cells: [
                                  actionCell,
                                  DataCell(
                                    Text(
                                      (_currentPage * _rowsPerPage + index + 1)
                                          .toString(),
                                    ),
                                  ),
                                  ...dataCells,
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
              // Pagination
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
