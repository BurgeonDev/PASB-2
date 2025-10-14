import 'package:flutter/material.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/pensioners_data_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/pensiontbl_data_screen.dart';

class Dashboard extends StatelessWidget {
  final void Function(int)? onNavigate;
  const Dashboard({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dashboardItems = [
      {
        'icon': Icons.person,
        'title': "Data Entry Form",
        'gradient': [Colors.blueAccent, Colors.lightBlueAccent],
      },
      {
        'icon': Icons.people,
        'title': "Data Summary",
        'gradient': [Colors.pinkAccent, Colors.orangeAccent],
      },
      {
        'icon': Icons.report,
        'title': "Data Reports",
        'gradient': [Colors.greenAccent, Colors.teal],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 4,
        backgroundColor: const Color(0xff1A73E8),
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔹 Top Dashboard Summary Cards
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: dashboardItems.map((item) {
                  return _buildDashboardCard(item);
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 🔹 Bottom Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDashboardColumn(context, [
                    'Data Entry Form',
                    'Family / NOK Form',
                    'Pension Cases progress Form',
                    'Benvolent Fund Data Entry Form',
                    'Hon Welfare Officers Data Entry Form',
                    'Pension Merger Form',
                  ]),
                  const SizedBox(width: 20),
                  _buildDashboardColumn(context, [
                    'Pensioners by Category',
                    'Pensioners by Rank',
                    'Pensioners by Regt/Corps',
                    'Pensioners by Army-NAVY-PA',
                    'Shuhada and Disabled',
                    'Benevolent Fund by Regt',
                    'Hon Wel Offrs Held Strength',
                    'Pension Cases by Regt/Corps',
                    'Pension Cases Overdue',
                    'Pension Cases Status',
                    'Pension Cases by Date',
                  ]),
                  const SizedBox(width: 20),
                  _buildDashboardColumn(context, [
                    'List of Shuhada',
                    'List of Disabled',
                    'List of Ben Fund Beneficiaries',
                    'List of Ben Fund Verification',
                    'List of Hon Welfare Officers',
                    'List of Extn Cases Hon Wel Offrs',
                    'List of Outstanding Pension Cases',
                    'Summary of Verified Record',
                  ]),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Card Widget (Top)
  Widget _buildDashboardCard(Map<String, dynamic> item) {
    return Container(
      width: 260,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: List<Color>.from(item['gradient']),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(item['icon'], size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item['title'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Dashboard Column Builder
  // 🔹 Dashboard Column Builder (with navigation)
  Widget _buildDashboardColumn(BuildContext context, List<String> titles) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: titles.map((title) {
          return DashboardButton(
            title: title,
            onTap: () {
              // 🔹 Navigation logic for each button
              switch (title) {
                case 'Data Entry Form':
                  onNavigate?.call(4);

                  break;

                case 'List of Shuhada':
                  onNavigate?.call(6);
                  break;

                // case 'Pension Cases progress Form':
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => const PensionProgressScreen(),
                //     ),
                //   );
                //   break;

                // case 'Benvolent Fund Data Entry Form':
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => const BenvolentFundScreen(),
                //     ),
                //   );
                //   break;

                // case 'Hon Welfare Officers Data Entry Form':
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) => const HonWelfareScreen()),
                //   );
                //   break;

                // case 'Pension Merger Form':
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => const PensionMergerScreen(),
                //     ),
                //   );
                //   break;

                default:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Coming soon: $title')),
                  );
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class DashboardButton extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  const DashboardButton({super.key, required this.title, this.onTap});

  @override
  State<DashboardButton> createState() => _DashboardButtonState();
}

class _DashboardButtonState extends State<DashboardButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _hover ? const Color(0xffE3F2FD) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hover ? const Color(0xff1A73E8) : Colors.grey.shade300,
              width: 1.3,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: _hover ? const Color(0xff1A73E8) : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
