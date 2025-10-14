import 'package:flutter/material.dart';
import 'package:testing_window_app/menu_screen.dart';

class AuthProvider extends ChangeNotifier {
  void login(String email, String password, BuildContext context) {
    try {
      if (email == 'muhammad@gmail.com' && password == 'Muhammad') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login success')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login Failed')));
      }
    } catch (e) {
      print('error:$e');
      throw (e);
    }
  }
}
