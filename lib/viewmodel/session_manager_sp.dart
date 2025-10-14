import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyName = "user_name";
  static const String _keyEmail = "user_email";
  static const String _keyPhone = "user_phone";

  // Save user session
  static Future<void> saveUserSession({
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
  }

  // Get session details
  static Future<Map<String, String?>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString(_keyName),
      "email": prefs.getString(_keyEmail),
      "phone": prefs.getString(_keyPhone),
    };
  }

  // Check if session exists
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyPhone);
  }

  // Clear session (Logout or App Close)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
