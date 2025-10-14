import 'package:flutter/material.dart';
import 'package:testing_window_app/login_screen.dart';
import 'package:testing_window_app/menu_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ Delay 3 seconds then navigate based on login status
    Future.delayed(const Duration(seconds: 3), () {
      if (widget.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MenuScreen(isSuperAdmin: false),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/WhatsApp Image 2025-10-08 at 9.54.46 AM.jpeg',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
