import 'package:flutter/material.dart';
import 'package:testing_window_app/Pages/Auth_Pages/user_create_login_screen.dart';
import 'package:testing_window_app/Pages/Auth_Pages/user_show_screen.dart';
import 'package:testing_window_app/Pages/Notifications.dart';
import 'package:testing_window_app/Pages/accounts.dart';
import 'package:testing_window_app/Pages/dashboard_screen.dart';
import 'package:testing_window_app/Pages/lu_data_section/Lu_pension_screen.dart';
import 'package:testing_window_app/Pages/lu_data_section/Lu_regtcorp_screen.dart';
import 'package:testing_window_app/Pages/lu_data_section/lu_rank_screen.dart';
import 'package:testing_window_app/Pages/location_config_tables/bank_screen.dart';
import 'package:testing_window_app/Pages/location_config_tables/dasb_screen.dart';
import 'package:testing_window_app/Pages/location_config_tables/directorate_screen.dart';
import 'package:testing_window_app/Pages/location_config_tables/district_screen.dart';
import 'package:testing_window_app/Pages/location_config_tables/location_tabbed_pane_screen.dart';
import 'package:testing_window_app/Pages/location_config_tables/province_screen.dart';
import 'package:testing_window_app/Pages/pension_claims_screens/send_pension_claim_screen.dart';
import 'package:testing_window_app/Pages/pension_claims_screens/view_all_pension_claim_screens.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/bentbl_data_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/familytbl_data_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/hwtbl_data_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/list_of_bendata_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/list_of_famData_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/list_of_hwData_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/list_of_pensioners_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/list_of_pensiontbl_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/pensioners_data_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/pensions_merger_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/pensiontbl_data_screen.dart';
import 'package:testing_window_app/Pages/reports.dart';
import 'package:testing_window_app/Pages/reports_section/list_of_disabled.dart';
import 'package:testing_window_app/Pages/reports_section/list_of_shuhada.dart';
import 'package:testing_window_app/Pages/settings.dart';
import 'package:testing_window_app/constants/images.dart';
import 'package:testing_window_app/login_screen.dart';
import 'package:testing_window_app/menu/menu_items.dart';
import 'package:testing_window_app/utils/responsive)extensionts.dart';
import 'package:testing_window_app/viewmodel/session_manager_sp.dart';

class MenuScreen extends StatefulWidget {
  final bool? isSuperAdmin;
  const MenuScreen({super.key, this.isSuperAdmin});

  @override
  State<MenuScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MenuScreen> {
  final controller = MenuItems();
  int currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    if (index < 0 || index > 31) return;
    pageController.jumpToPage(index);
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopNavBar(context),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              children: const [
                Dashboard(),
                Accounts(),
                AttendanceScreen(),
                ReportScreen(),
                PensionersDataScreen(),
                Settings(),
                ListOfShuhada(),
                ListOfDisabled(),
                ListOfPensionersScreen(),
                UserCreateScreen(),
                UserShowScreen(),
                SendPensionClaimScreen(),
                ViewAllPensionClaimScreens(),
                Placeholder(),
                LuRankScreen(),
                LuPensionScreen(),
                LuRegtCorpsScreen(),
                ProvinceScreen(),
                DirectorateScreen(),
                DasbScreen(),
                DistrictScreen(),
                BankScreen(),
                LocationTabbedPaneScreen(),
                BenDataScreen(),
                ListOfBenDataScreen(),
                FamilytblDataScreen(),
                ListOfFamilyDataScreen(),
                HWDataScreen(),
                ListOfHWDataScreen(),
                PensiontblDataScreen(),
                ListOfPensionDataScreen(),
                PensionMergerFormScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      height: context.height * 0.08, // ✅ Responsive height
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.005),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.8),
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: context.width * 0.035,
            height: context.width * 0.035,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(appLogo, fit: BoxFit.cover),
          ),
          SizedBox(width: context.width * 0.008),
          _navButton(index: 0, icon: Icons.dashboard, title: "Dashboard"),
          if (widget.isSuperAdmin!) _accountsMenuCombo(),
          _navButton(index: 2, icon: Icons.notifications, title: "Attendance"),
          _reportsMenuCombo(),
          _pensionersMenuCombo(),
          _pensionClaimsMenuCombo(),
          tables(),
          _navButton(index: 5, icon: Icons.settings, title: "Settings"),
          const Spacer(),
          _logoutButton(),
        ],
      ),
    );
  }

  Widget _navButton({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = currentIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.003),
      child: InkWell(
        onTap: () => _navigateToPage(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.width * 0.007,
            vertical: context.height * 0.008,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: context.width * 0.013),
              SizedBox(width: context.width * 0.004),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.width * 0.009,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountsMenuCombo() {
    return _popupMenu("User Accounts", Icons.account_circle, [
      const PopupMenuItem<int>(value: 9, child: Text("Create User")),
      const PopupMenuItem<int>(value: 10, child: Text("List of Users")),
    ]);
  }

  Widget _reportsMenuCombo() {
    return _popupMenu("Reports", Icons.insert_chart, const [
      PopupMenuItem<int>(value: 6, child: Text("List of Shuhada")),
      PopupMenuItem<int>(value: 7, child: Text("List of Disabled")),
      PopupMenuItem<int>(
        value: 3,
        child: Text("List of Ben Fund Beneficiaries"),
      ),
      PopupMenuItem<int>(
        value: 3,
        child: Text("List of Ben Fund Verification"),
      ),
      PopupMenuItem<int>(value: 3, child: Text("List of Hon Welfare Officers")),
      PopupMenuItem<int>(
        value: 3,
        child: Text("List of Outstanding Pension Case"),
      ),
      PopupMenuItem<int>(value: 3, child: Text("Summary of Verified Record")),
      PopupMenuItem<int>(
        value: 3,
        child: Text("List of Extn Cases Hon Wel Offrs"),
      ),
      PopupMenuItem<int>(value: 3, child: Text("Summary Data")),
    ]);
  }

  Widget _pensionersMenuCombo() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: Colors.white,
      onSelected: (int value) => _navigateToPage(value),
      itemBuilder: (context) => const [
        PopupMenuItem<int>(value: 4, child: Text("Add Basic Data")),
        PopupMenuItem<int>(value: 8, child: Text("List Basic Data")),
        PopupMenuItem<int>(value: 23, child: Text("Add ben Data")),
        PopupMenuItem<int>(value: 24, child: Text("List ben data")),
        PopupMenuItem<int>(value: 25, child: Text("Add family data")),
        PopupMenuItem<int>(value: 26, child: Text("List family data")),
        PopupMenuItem<int>(value: 27, child: Text("Add HWO data")),
        PopupMenuItem<int>(value: 28, child: Text("List HWO data")),
        PopupMenuItem<int>(value: 29, child: Text("Add Pension data")),
        PopupMenuItem<int>(value: 30, child: Text("List Pension data")),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.elderly, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text("Pensioners Data", style: TextStyle(color: Colors.white)),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pensionClaimsMenuCombo() {
    return _popupMenu("Pension Claims", Icons.assignment, const [
      PopupMenuItem<int>(value: 11, child: Text("Send Pension Claim")),
      PopupMenuItem<int>(value: 12, child: Text("View All Pension Claims")),
    ]);
  }

  Widget tables() {
    return _popupMenu("Common Data", Icons.table_chart, const [
      PopupMenuItem<int>(value: 21, child: Text("Banks")),
      PopupMenuItem<int>(value: 22, child: Text("Location")),
      PopupMenuItem<int>(value: 15, child: Text("Pension Type")),
      PopupMenuItem<int>(value: 14, child: Text("Rank")),
      PopupMenuItem<int>(value: 16, child: Text("RegtCorps")),
    ]);
  }

  Widget _popupMenu(
    String title,
    IconData icon,
    List<PopupMenuItem<int>> items,
  ) {
    return PopupMenuButton<int>(
      offset: Offset(0, context.height * 0.05),
      color: Colors.white,
      onSelected: (int value) => _navigateToPage(value),
      itemBuilder: (context) => items,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.width * 0.003),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.width * 0.007,
            vertical: context.height * 0.008,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: context.width * 0.013),
              SizedBox(width: context.width * 0.004),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.width * 0.009,
                ),
              ),
              SizedBox(width: context.width * 0.003),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return TextButton.icon(
      onPressed: () async {
        await SessionManager.clearSession();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: Text(
        'Logout',
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: context.width * 0.009,
        ),
      ),
    );
  }
}

// ✅ Responsive sidebar container
Widget background(BuildContext context, Widget child) {
  return Container(
    width: context.width * 0.18, // 18% of total width
    height: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(context.width * 0.006),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(.8),
          blurRadius: 1,
          spreadRadius: 0,
        ),
      ],
      color: Colors.black,
    ),
    child: child,
  );
}
