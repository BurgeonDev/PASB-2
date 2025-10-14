import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/sqlite/lurank_database_helper.dart';

class LuRankScreen extends StatefulWidget {
  const LuRankScreen({super.key});

  @override
  State<LuRankScreen> createState() => _LuRankScreenState();
}

class _LuRankScreenState extends State<LuRankScreen> {
  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _acronymController = TextEditingController();
  final TextEditingController _rankUrduController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedForce = 'Forces';
  String? _selectedCategory = 'Category';

  // Separate variables for table filters
  String? _tableFilterForce = null;
  String? _tableFilterCategory = null;

  List<Map<String, dynamic>> _rankList = [];
  int? _editingId;

  final List<String> _forces = ['ARMY', 'Navy', 'PAF'];
  final List<String> _categories = ['Offrs', 'JCOs', 'Sldrs'];
  final String _pasbName = "PASB";

  @override
  void initState() {
    super.initState();
    _loadRanks();
  }

  Future<void> _loadRanks() async {
    final data = await RankDatabase.instance.getAllRanks();
    setState(() {
      _rankList = data;
    });
  }

  Future<void> _saveRank() async {
    final now = DateTime.now().toIso8601String();
    final rankData = {
      'rank': _rankController.text.trim(),
      'acronym': _acronymController.text.trim(),
      'forces': _selectedForce ?? '',
      'rank_category': _selectedCategory ?? '',
      'rank_urdu': _rankUrduController.text.trim(),
      'created_by': _pasbName,
      'updated_by': _pasbName,
      'created_at': now,
      'updated_at': now,
    };

    if (_editingId == null) {
      await RankDatabase.instance.insertRank(rankData);
    } else {
      rankData['id'] = _editingId!.toString();
      rankData['updated_at'] = now;
      await RankDatabase.instance.updateRank(rankData);
    }

    _clearForm();
    _loadRanks();
  }

  void _editRank(Map<String, dynamic> rank) {
    setState(() {
      _editingId = rank['id'] is int
          ? rank['id']
          : int.tryParse(rank['id'].toString());
      _rankController.text = rank['rank'] ?? '';
      _acronymController.text = rank['acronym'] ?? '';
      _rankUrduController.text = rank['rank_urdu'] ?? '';
      _selectedForce = rank['forces'];
      _selectedCategory = rank['rank_category'];
    });
  }

  Future<void> _deleteRank(int id) async {
    await RankDatabase.instance.deleteRank(id);
    _loadRanks();
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _rankController.clear();
      _acronymController.clear();
      _rankUrduController.clear();
      _selectedForce = null;
      _selectedCategory = null;
    });
  }

  void _clearFilters() {
    setState(() {
      _tableFilterForce = null;
      _tableFilterCategory = null;
      _searchController.clear();
    });
  }

  String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoString;
    }
  }

  List<Map<String, dynamic>> _applyFilters() {
    return _rankList.where((rank) {
      final matchesForce =
          _tableFilterForce == null || rank['forces'] == _tableFilterForce;
      final matchesCategory =
          _tableFilterCategory == null ||
          rank['rank_category'] == _tableFilterCategory;
      final search = _searchController.text.toLowerCase();
      final matchesSearch =
          search.isEmpty ||
          rank['rank'].toLowerCase().contains(search) ||
          rank['acronym'].toLowerCase().contains(search) ||
          rank['forces'].toLowerCase().contains(search) ||
          rank['rank_category'].toLowerCase().contains(search);
      return matchesForce && matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _exportPDF(List<Map<String, dynamic>> data) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Table.fromTextArray(
              headers: [
                'Rank',
                'Acronym',
                'Force',
                'Category',
                'Rank Urdu',
                'Created By',
                'Updated By',
                'Created At',
                'Updated At',
              ],
              data: data.map((e) {
                return [
                  e['rank'] ?? '',
                  e['acronym'] ?? '',
                  e['forces'] ?? '',
                  e['rank_category'] ?? '',
                  e['rank_urdu'] ?? '',
                  e['created_by'] ?? '',
                  e['updated_by'] ?? '',
                  formatDate(e['created_at']),
                  formatDate(e['updated_at']),
                ];
              }).toList(),
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/LU_Ranks.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF exported successfully: ${file.path}')),
      );

      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
    }
  }

  Future<void> _exportExcel(List<Map<String, dynamic>> data) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['LU_Ranks'];

      // Add header row
      sheet.appendRow([
        'Rank',
        'Acronym',
        'Force',
        'Category',
        'Rank Urdu',
        'Created By',
        'Updated By',
        'Created At',
        'Updated At',
      ]);

      // Add data rows
      for (var rank in data) {
        sheet.appendRow([
          rank['rank'] ?? '',
          rank['acronym'] ?? '',
          rank['forces'] ?? '',
          rank['rank_category'] ?? '',
          rank['rank_urdu'] ?? '',
          rank['created_by'] ?? '',
          rank['updated_by'] ?? '',
          formatDate(rank['created_at']),
          formatDate(rank['updated_at']),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/LU_Ranks.xlsx";
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

  @override
  Widget build(BuildContext context) {
    final filteredRanks = _applyFilters();
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("Rank Listing"),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 10),
            //  Expanded(
            //       child: TextField(
            //         controller: _searchController,
            //         decoration: const InputDecoration(
            //           hintText: 'Search ranks...',
            //           border: OutlineInputBorder(),
            //           prefixIcon: Icon(Icons.search),
            //         ),
            //         onChanged: (val) => setState(() {}),
            //       ),
            //     ),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 40,
                  child: ButtonComponent(
                    buttonColor: Colors.grey,
                    ontap: () {
                      _exportPDF(_applyFilters());
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
                      _exportExcel(_applyFilters()); // <-- apply filters here
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
                    ontap: _clearFilters, // <-- clear filters
                    title: 'Clear Filters',
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search ranks...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildRankDataTable(filteredRanks)),
          ],
        ),
      ),
    );
  }

  Widget _buildRankDataTable(List<Map<String, dynamic>> data) {
    final int rowsPerPage = 10;
    int currentPage = 0;

    List<Map<String, dynamic>> paginated() {
      final start = currentPage * rowsPerPage;
      final end = start + rowsPerPage;
      return data.sublist(start, end > data.length ? data.length : end);
    }

    return StatefulBuilder(
      builder: (context, setStateTable) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width, // full screen width
                  child: DataTable(
                    columnSpacing: 20,
                    columns: [
                      DataColumn(label: Text("Actions")),
                      DataColumn(label: Text("S No.")),
                      DataColumn(label: Text("Rank")),
                      DataColumn(label: Text("Acronym")),
                      DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(
                            width: 150, // adjust width as needed
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: "Force",

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // circular border
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              value: _tableFilterForce,
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text("All Forces"),
                                ),
                                ..._forces.map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _tableFilterForce = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: DropdownButton<String>(
                          value: _tableFilterCategory,
                          hint: Text("Category"),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text("All Categories"),
                            ),
                            ..._categories.map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _tableFilterCategory = value;
                            });
                          },
                        ),
                      ),
                      DataColumn(label: Text("Rank Urdu")),
                      DataColumn(label: Text("Created By")),
                      DataColumn(label: Text("Updated By")),
                      DataColumn(label: Text("Created At")),
                      DataColumn(label: Text("Updated At")),
                    ],
                    rows: paginated().asMap().entries.map((entry) {
                      final index = entry.key;
                      final rank = entry.value;
                      final seqNo = currentPage * rowsPerPage + index + 1;

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _editRank(rank),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteRank(rank['id'] as int),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(seqNo.toString())),
                          DataCell(Text(rank['rank'] ?? '')),
                          DataCell(Text(rank['acronym'] ?? '')),
                          DataCell(Text(rank['forces'] ?? '')),
                          DataCell(Text(rank['rank_category'] ?? '')),
                          DataCell(Text(rank['rank_urdu'] ?? '')),
                          DataCell(Text(rank['created_by'] ?? '')),
                          DataCell(Text(rank['updated_by'] ?? '')),
                          DataCell(Text(formatDate(rank['created_at']))),
                          DataCell(Text(formatDate(rank['updated_at']))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: currentPage > 0
                      ? () => setStateTable(() => currentPage--)
                      : null,
                ),
                Text(
                  "Page ${currentPage + 1} of ${(data.length / rowsPerPage).ceil()}",
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: (currentPage + 1) * rowsPerPage < data.length
                      ? () => setStateTable(() => currentPage++)
                      : null,
                ),
              ],
            ),
          ],
        );
      },
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

  Widget _dropdownField({
    required String title,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
      value: value,
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  Widget _buildForm() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Row 1: Rank, Acronym, Force ---
            Row(
              children: [
                Expanded(child: _textField(_rankController, 'Rank')),
                const SizedBox(width: 10),
                Expanded(child: _textField(_acronymController, 'Acronym')),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Force',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    value: _selectedForce == 'Forces' ? null : _selectedForce,
                    items: _forces
                        .map(
                          (force) => DropdownMenuItem(
                            value: force,
                            child: Text(force),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedForce = value ?? 'Forces';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- Row 2: Category, Rank Urdu, empty/placeholder ---
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    value: _selectedCategory == 'Category'
                        ? null
                        : _selectedCategory,
                    items: _categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'Category';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _textField(_rankUrduController, 'Rank Urdu')),
                const SizedBox(width: 10),
                Expanded(child: Container()), // placeholder for alignment
              ],
            ),

            const SizedBox(height: 20),

            // --- Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveRank,
                  icon: const Icon(Icons.save),
                  label: Text(_editingId == null ? 'Save' : 'Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.clear),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
