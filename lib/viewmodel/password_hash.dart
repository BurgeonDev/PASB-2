import 'package:bcrypt/bcrypt.dart';

class PasswordUtils {
  static String hashPassword(String password, {int cost = 10}) {
    final salt = BCrypt.gensalt();
    final hashed = BCrypt.hashpw(password, salt);
    return hashed;
  }

  static bool verifyPassword(String password, String hash) {
    try {
      return BCrypt.checkpw(password, hash);
    } catch (_) {
      return false;
    }
  }
}
