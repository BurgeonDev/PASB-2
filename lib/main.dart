import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:testing_window_app/splash_screen.dart';
import 'package:testing_window_app/viewmodel/account_provider.dart';
import 'package:testing_window_app/viewmodel/auth_provider.dart';
import 'package:testing_window_app/viewmodel/session_manager_sp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize sqflite for desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // ✅ Initialize window manager (to detect close)
  await windowManager.ensureInitialized();

  // ✅ Handle window close event
  windowManager.addListener(MyWindowListener());

  // ✅ Check if user is logged in
  bool loggedIn = await SessionManager.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(isLoggedIn: loggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pension Desktop App',
      home: SplashScreen(isLoggedIn: isLoggedIn),
    );
  }
}

// ✅ Custom listener to detect window close event
class MyWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    // 🧠 This runs when user clicks the ❌ close button
    await SessionManager.clearSession();
    await windowManager.destroy(); // actually close the window
  }
}
