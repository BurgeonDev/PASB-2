import 'package:flutter/material.dart';

// Import your location screens
import 'province_screen.dart';
import 'directorate_screen.dart';
import 'dasb_screen.dart';
import 'district_screen.dart';

class LocationTabbedPaneScreen extends StatefulWidget {
  const LocationTabbedPaneScreen({super.key});

  @override
  State<LocationTabbedPaneScreen> createState() =>
      _LocationTabbedPaneScreenState();
}

class _LocationTabbedPaneScreenState extends State<LocationTabbedPaneScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Province'),
    Tab(text: 'Directorate'),
    Tab(text: 'DASB'),
    Tab(text: 'District'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        backgroundColor: const Color(0xff27ADF5),
        title: const Text(
          'Location Management',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true, // horizontal scroll for better UX
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProvinceScreen(),
          DirectorateScreen(),
          DasbScreen(),
          DistrictScreen(),
        ],
      ),
    );
  }
}
