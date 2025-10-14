import 'package:flutter/material.dart';
import 'package:testing_window_app/Pages/Notifications.dart';
import 'package:testing_window_app/Pages/accounts.dart';
import 'package:testing_window_app/Pages/dashboard_screen.dart';
import 'package:testing_window_app/Pages/pensioners_section.dart/pensioners_data_screen.dart';
import 'package:testing_window_app/Pages/reports.dart';
import 'package:testing_window_app/Pages/settings.dart';
import 'package:testing_window_app/components/menu_details.dart';

class MenuItems {
  List<MenuDetails> items = [
    MenuDetails(title: 'Dashboard', icon: Icons.home, page: Dashboard()),
    MenuDetails(
      title: 'User Accounts',
      icon: Icons.account_circle_rounded,
      page: Accounts(),
    ),
    MenuDetails(
      title: 'Attendance',
      icon: Icons.fingerprint,
      page: AttendanceScreen(),
    ),
    MenuDetails(title: 'Reports', icon: Icons.addchart, page: ReportScreen()),
    MenuDetails(
      title: 'Pensioners Data',
      icon: Icons.pest_control,
      page: PensionersDataScreen(),
    ),
    MenuDetails(title: 'Settings', icon: Icons.settings, page: Settings()),
  ];
}
