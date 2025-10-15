import 'package:flutter/material.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/utils/responsive)extensionts.dart';

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
    final isWide = context.width > 1000;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        title: Text(
          "Employee Attendance",
          style: TextStyle(
            fontSize: context.width * 0.012, // ✅ responsive title size
          ),
        ),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: Padding(
        padding: EdgeInsets.all(context.width * 0.015),
        child: Container(
          padding: EdgeInsets.all(context.width * 0.01),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.width * 0.005),
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
              /// 🔹 Top Buttons
              Wrap(
                spacing: context.width * 0.008,
                runSpacing: context.height * 0.01,
                children: [
                  SizedBox(
                    width: context.width * 0.06,
                    height: context.height * 0.06,
                    child: ButtonComponent(
                      buttonColor: Colors.grey,
                      ontap: () {},
                      title: 'PDF',
                    ),
                  ),
                  SizedBox(
                    width: context.width * 0.07,
                    height: context.height * 0.06,
                    child: ButtonComponent(
                      buttonColor: Colors.grey,
                      ontap: () {},
                      title: 'Excel',
                    ),
                  ),
                  SizedBox(
                    width: context.width * 0.12,
                    height: context.height * 0.06,
                    child: ButtonComponent(
                      buttonColor: Colors.grey,
                      ontap: () {},
                      title: 'Clear Filters',
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.height * 0.015),

              /// 🔹 Header + Search
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Attendance Records",
                    style: TextStyle(
                      fontSize: context.width * 0.014,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? context.width * 0.25 : context.width * 0.5,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search employee...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.width * 0.004,
                          ),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.all(context.width * 0.005),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.height * 0.015),

              /// 🔹 Table Section
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
                                  columnSpacing: context.width * 0.02,
                                  dataRowMinHeight: context.height * 0.06,
                                  dataRowMaxHeight: context.height * 0.08,
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
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blueAccent,
                                                  size: context.width * 0.012,
                                                ),
                                                onPressed: () {},
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.redAccent,
                                                  size: context.width * 0.012,
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
                                              fontWeight: FontWeight.w600,
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

              /// 🔹 Pagination Controls
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: context.height * 0.01,
                  horizontal: context.width * 0.01,
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
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: context.width * 0.012,
                          ),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text(
                          "Page ${_currentPage + 1} of ${(_filteredRows.length / _rowsPerPage).ceil()}",
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: context.width * 0.012,
                          ),
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
