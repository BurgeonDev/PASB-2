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
import 'package:testing_window_app/Pages/pensioners_section.dart/pensiontbl_data_screen.dart';
import 'package:testing_window_app/Pages/reports.dart';
import 'package:testing_window_app/Pages/reports_section/list_of_disabled.dart';
import 'package:testing_window_app/Pages/reports_section/list_of_shuhada.dart';
import 'package:testing_window_app/Pages/settings.dart';
import 'package:testing_window_app/constants/images.dart';
import 'package:testing_window_app/login_screen.dart';
import 'package:testing_window_app/menu/menu_items.dart';
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
  bool selectedItem = false;
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
    if (index < 0 || index > 30) return; // 🛡️ guard

    pageController.jumpToPage(index);
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopNavBar(),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              children: [
                Dashboard(onNavigate: _navigateToPage),

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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Removed old sidebar helpers and developer links (not used in top bar)

  Widget _buildTopNavBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
            width: 44,
            height: 44,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(appLogo, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          _navButton(index: 0, icon: Icons.dashboard, title: "Dashboard"),
          if (widget.isSuperAdmin!) _accountsMenuCombo(),
          _navButton(index: 2, icon: Icons.notifications, title: "Attendance"),
          _reportsMenuCombo(),
          _pensionersMenuCombo(),
          _pensionClaimsMenuCombo(),
          tables(),
          // _commonDataMenuCombo(),
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
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => _navigateToPage(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountsMenuCombo() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: Colors.white,
      onSelected: (int value) => _navigateToPage(value),
      itemBuilder: (context) => const [
        PopupMenuItem<int>(value: 9, child: Text("Create User")),
        PopupMenuItem<int>(value: 10, child: Text("List of Users")),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.account_circle, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text("User Accounts", style: TextStyle(color: Colors.white)),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportsMenuCombo() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: Colors.white,
      onSelected: (int value) => _navigateToPage(value),
      itemBuilder: (context) => const [
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
        PopupMenuItem<int>(
          value: 3,
          child: Text("List of Hon Welfare Officers"),
        ),
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
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.insert_chart, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text("Reports", style: TextStyle(color: Colors.white)),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 2),
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

  // Widget _commonDataMenuCombo() {
  //   return PopupMenuButton<int>(
  //     offset: const Offset(0, 40),
  //     color: Colors.white,
  //     onSelected: (int value) => _navigateToPage(value),
  //     itemBuilder: (context) => const [
  //       // PopupMenuItem<int>(value: 14, child: Text("Rank")),
  //       // PopupMenuItem<int>(value: 15, child: Text("Pension Type")),
  //       // PopupMenuItem<int>(value: 16, child: Text("Regt/Corps")),
  //       // PopupMenuItem<int>(value: 13, child: Text("Designations")),
  //       // PopupMenuItem<int>(value: 13, child: Text("Grades")),
  //     ],
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 4),
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  //         decoration: BoxDecoration(
  //           color: Colors.transparent,
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Row(
  //           children: const [
  //             Icon(Icons.dataset, color: Colors.white, size: 18),
  //             SizedBox(width: 6),
  //             Text("Common Data", style: TextStyle(color: Colors.white)),
  //             SizedBox(width: 4),
  //             Icon(Icons.arrow_drop_down, color: Colors.white),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _pensionClaimsMenuCombo() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: Colors.white,
      onSelected: (int value) => _navigateToPage(value),
      itemBuilder: (context) => const [
        PopupMenuItem<int>(value: 11, child: Text("Send Pension Claim")),
        PopupMenuItem<int>(value: 12, child: Text("View All Pension Claims")),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.assignment, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text("Pension Claims", style: TextStyle(color: Colors.white)),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // tables
  Widget tables() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: Colors.white,
      onSelected: (int value) => _navigateToPage(value),
      itemBuilder: (context) => const [
        PopupMenuItem<int>(value: 21, child: Text("Banks")),
        PopupMenuItem<int>(value: 22, child: Text("Location")),
        PopupMenuItem<int>(value: 15, child: Text("Pension Type")),
        PopupMenuItem<int>(value: 14, child: Text("Rank")),
        PopupMenuItem<int>(value: 16, child: Text("Regt/Corps")),
        // PopupMenuItem<int>(value: 15, child: Text("Province")),
        // PopupMenuItem<int>(value: 16, child: Text("Directorate")),
        // PopupMenuItem<int>(value: 17, child: Text("DASB")),
        // PopupMenuItem<int>(value: 18, child: Text("District")),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.assignment, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text("Common Data", style: TextStyle(color: Colors.white)),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return TextButton.icon(
      onPressed: () async {
        // ✅ Clear the saved session first
        await SessionManager.clearSession();

        // ✅ Then navigate to Login screen and remove all previous routes
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text(
        'Logout',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Sidebar background container
Widget background(Widget child) {
  return Container(
    //  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    width: 220,
    height: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
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
