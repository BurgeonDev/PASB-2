import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dashboardItems = [
      {
        'icon': Icons.person,
        'title': "Today's Open Cases",
        'subtitle': "21",
        'color': Colors.white,
        'borderColor': Colors.green,
      },
      {
        'icon': Icons.people,
        'title': "Today's Rejected Cases",
        'subtitle': "44",
        'color': Colors.white,
        'borderColor': Colors.red,
      },
      {
        'icon': Icons.report,
        'title': "Today's In-progress Cases",
        'subtitle': "6",
        'color': Colors.white,
        'borderColor': Colors.blue,
      },
      {
        'icon': Icons.report,
        'title': "Today's Pension Claims",
        'subtitle': "11",
        'color': Colors.white,
        'borderColor': Colors.yellow,
      },
    ];

    /// 🔹 Dynamic data for lower containers
    final List<Map<String, dynamic>> dasbboardContainers = [
      {
        'title': 'Top 5 DASBs by Open Cases',
        'borderColor': Colors.white,
        'items': [
          {'icon': Icons.home, 'title': 'Islamabad', 'subtitle': '8'},
          {'icon': Icons.home, 'title': 'Karachi', 'subtitle': '6'},
          {'icon': Icons.home, 'title': 'Peshawar', 'subtitle': '4'},
          {'icon': Icons.home, 'title': 'Multan', 'subtitle': '3'},
          {'icon': Icons.home, 'title': 'Hyderabad', 'subtitle': '1'},
        ],
      },
      {
        'title': 'Top 5 DASBs by Finalized Cases',
        'borderColor': Colors.white,
        'items': [
          {'icon': Icons.home, 'title': 'Rawalpindi', 'subtitle': '5'},
          {'icon': Icons.home, 'title': 'Lahore', 'subtitle': '4'},
          {'icon': Icons.home, 'title': 'Peshawar', 'subtitle': '3'},
          {'icon': Icons.home, 'title': 'Islamabad', 'subtitle': '2'},
          {'icon': Icons.home, 'title': 'Karachi', 'subtitle': '1'},
        ],
      },
      {
        'title': 'Top 5 DASBs by Rejected Cases',
        'borderColor': Colors.white,
        'items': [
          {'icon': Icons.home, 'title': 'Multan', 'subtitle': '8'},
          {'icon': Icons.home, 'title': 'Hyderabad', 'subtitle': '6'},
          {'icon': Icons.home, 'title': 'Peshawar', 'subtitle': '5'},
          {'icon': Icons.home, 'title': 'Rawalpindi', 'subtitle': '5'},
          {'icon': Icons.home, 'title': 'Lahore', 'subtitle': '4'},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xff27ADF5),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ===== Top Horizontal Dashboard Cards =====
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item['color'],
                        border: Border(
                          bottom: BorderSide(
                            color: item['borderColor'],
                            width: 5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item['icon'], size: 40, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    item['subtitle'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 100),

              // ===== Bottom 3 Horizontal Containers =====
              SizedBox(
                height: 400,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dasbboardContainers.length,
                  itemBuilder: (context, index) {
                    final section = dasbboardContainers[index];
                    final items = section['items'] as List<dynamic>;
                    return Container(
                      height: 400,
                      width: 400,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: section['borderColor'],
                            width: 5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 🔹 Dynamic Title
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: section['borderColor'],
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  section['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          // 🔹 Dynamic List of Items
                          Expanded(
                            child: ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (context, _) => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Center(
                                  child: SizedBox(
                                    width:
                                        350, // ⬅️ adjust this value to control line length
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder: (context, i) {
                                final item = items[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(item['icon'],
                                              color: Colors.grey),
                                          const SizedBox(width: 5),
                                          Text(
                                            item['title'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        item['subtitle'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'view All',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blueAccent),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.blueAccent,
                                size: 15,
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
