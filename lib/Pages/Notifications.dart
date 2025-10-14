import 'package:flutter/material.dart';
import 'package:testing_window_app/components/button_component.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Dummy data
  List<Map<String, dynamic>> _rows = [
    {
      's_no': 1,
      'employee_name': 'Ali Khan',
      'designation': 'Clerk',
      'check_in': '09:00 AM',
      'check_out': '05:00 PM',
      'status': 'Present',
    },
    {
      's_no': 2,
      'employee_name': 'Sara Ahmed',
      'designation': 'Captain',
      'check_in': '09:15 AM',
      'check_out': '05:10 PM',
      'status': 'Present',
    },
    {
      's_no': 3,
      'employee_name': 'Bilal Hussain',
      'designation': 'Waiter',
      'check_in': '-',
      'check_out': '-',
      'status': 'Absent',
    },
  ];

  List<Map<String, dynamic>> _filteredRows = [];
  final TextEditingController _searchController = TextEditingController();

  int _rowsPerPage = 5;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredRows = _rows;
    _searchController.addListener(_applySearch);
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredRows = _rows
          .where(
            (row) => row.values.any(
              (val) => val.toString().toLowerCase().contains(query),
            ),
          )
          .toList();
    });
  }

  List<Map<String, dynamic>> get _paginatedRows {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (_currentPage + 1) * _rowsPerPage;
    return _filteredRows.sublist(
      startIndex,
      endIndex > _filteredRows.length ? _filteredRows.length : endIndex,
    );
  }

  void _onSort(int columnIndex, String key, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filteredRows.sort((a, b) {
        final aValue = a[key].toString();
        final bValue = b[key].toString();
        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: const Text("Employee Attendance"),
        backgroundColor: const Color(0xff27ADF5),
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
              // Buttons row
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 40,
                    child: ButtonComponent(
                      buttonColor: Colors.grey,
                      ontap: () {
                        //   _exportToPdf();
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
                        //   _exportToExcel();
                        //      print('object');
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
                        // setState(() {
                        //   for (var key in _selectedFilters.keys) {
                        //     _selectedFilters[key] = null;
                        //   }
                        //   _searchController.clear();
                        //   _applyFilters();
                        // });
                      },
                      title: 'Clear Filters',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Header + Search
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Attendance Records",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search employee...",
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

              // Table
              // Table
              Expanded(
                child: _filteredRows.isEmpty
                    ? const Center(child: Text("No records found"))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  columnSpacing: 20,
                                  dataRowMinHeight: 45,
                                  dataRowMaxHeight: 55,
                                  columns: [
                                    const DataColumn(
                                      label: Text(
                                        "Actions",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: const Text('S No.'),
                                      onSort: (i, asc) =>
                                          _onSort(i, 's_no', asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Employee Name'),
                                      onSort: (i, asc) =>
                                          _onSort(i, 'employee_name', asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Designation'),
                                      onSort: (i, asc) =>
                                          _onSort(i, 'designation', asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Check In'),
                                      onSort: (i, asc) =>
                                          _onSort(i, 'check_in', asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Check Out'),
                                      onSort: (i, asc) =>
                                          _onSort(i, 'check_out', asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Status'),
                                      onSort: (i, asc) =>
                                          _onSort(i, 'status', asc),
                                    ),
                                  ],
                                  rows: _paginatedRows.map((row) {
                                    final status = row['status'];
                                    final statusColor = status == 'Present'
                                        ? Colors.green
                                        : Colors.red;

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blueAccent,
                                                  size: 18,
                                                ),
                                                onPressed: () {},
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.redAccent,
                                                  size: 18,
                                                ),
                                                onPressed: () {},
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(row['s_no'].toString())),
                                        DataCell(Text(row['employee_name'])),
                                        DataCell(Text(row['designation'])),
                                        DataCell(Text(row['check_in'])),
                                        DataCell(Text(row['check_out'])),
                                        DataCell(
                                          Text(
                                            status,
                                            style: TextStyle(
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Pagination Controls
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
                          items: [2, 5, 7, 10]
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
