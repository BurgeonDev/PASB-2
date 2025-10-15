import 'package:flutter/material.dart';
import 'package:testing_window_app/utils/responsive)extensionts.dart'; // ✅ make sure your extension is imported

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.width * 0.015), // responsive padding
          child: Column(
            children: [
              SizedBox(height: context.height * 0.02),

              // 🔹 Top Dashboard Summary Cards
              Wrap(
                alignment: WrapAlignment.center,
                spacing: context.width * 0.02,
                runSpacing: context.height * 0.02,
                children: dashboardItems.map((item) {
                  return _buildDashboardCard(context, item);
                }).toList(),
              ),

              SizedBox(height: context.height * 0.03),

              // 🔹 Bottom Section
              LayoutBuilder(
                builder: (context, constraints) {
                  // Adjust number of columns depending on screen width
                  final bool isSmall = context.width < 1000;

                  return Flex(
                    direction: isSmall ? Axis.vertical : Axis.horizontal,
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
                      SizedBox(
                        width: isSmall ? 0 : context.width * 0.015,
                        height: isSmall ? context.height * 0.02 : 0,
                      ),
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
                      SizedBox(
                        width: isSmall ? 0 : context.width * 0.015,
                        height: isSmall ? context.height * 0.02 : 0,
                      ),
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
                  );
                },
              ),

              SizedBox(height: context.height * 0.08),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Responsive Card Widget (Top)
  Widget _buildDashboardCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      width: context.width * 0.2, // 20% of screen width
      height: context.height * 0.08, // 8% of screen height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: List<Color>.from(item['gradient']),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.width * 0.01),
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
          SizedBox(width: context.width * 0.01),
          CircleAvatar(
            radius: context.width * 0.02,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              item['icon'],
              size: context.width * 0.02,
              color: Colors.white,
            ),
          ),
          SizedBox(width: context.width * 0.015),
          Expanded(
            child: Text(
              item['title'],
              style: TextStyle(
                fontSize: context.width * 0.011,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Dashboard Column Builder (Responsive)
  Widget _buildDashboardColumn(BuildContext context, List<String> titles) {
    return Container(
      width: context.width * 0.22, // 22% of screen width
      padding: EdgeInsets.symmetric(
        vertical: context.height * 0.02,
        horizontal: context.width * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.width * 0.008),
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
              switch (title) {
                case 'Data Entry Form':
                  onNavigate?.call(4);
                  break;
                case 'List of Shuhada':
                  onNavigate?.call(6);
                  break;
                case 'List of Disabled':
                  onNavigate?.call(7);
                  break;
                case 'Family / NOK Form':
                  onNavigate?.call(25);
                  break;
                case 'Benvolent Fund Data Entry Form':
                  onNavigate?.call(23);
                  break;
                case 'Hon Welfare Officers Data Entry Form':
                  onNavigate?.call(27);
                  break;
                case 'Pension Merger Form':
                  onNavigate?.call(31);
                  break;
                case 'Pensioners by Category':
                  onNavigate?.call(15);
                  break;
                case 'Pensioners by Rank':
                  onNavigate?.call(14);
                  break;
                case 'Pensioners by Regt/Corps':
                  onNavigate?.call(16);
                  break;
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
          margin: EdgeInsets.symmetric(vertical: context.height * 0.007),
          padding: EdgeInsets.symmetric(
            vertical: context.height * 0.015,
            horizontal: context.width * 0.008,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _hover ? const Color(0xffE3F2FD) : Colors.white,
            borderRadius: BorderRadius.circular(context.width * 0.008),
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
                fontSize: context.width * 0.011,
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
