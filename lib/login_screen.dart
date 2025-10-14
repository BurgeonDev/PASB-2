import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_window_app/viewmodel/password_hash.dart';

import 'package:provider/provider.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/components/textfield_component.dart';
import 'package:testing_window_app/components/toast_message.dart';
import 'package:testing_window_app/constants/images.dart';
import 'package:testing_window_app/sqlite/user_create_db_helper.dart';
import 'package:testing_window_app/viewmodel/auth_provider.dart';
import 'package:testing_window_app/viewmodel/session_manager_sp.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu_screen.dart';
import 'model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isPasswordVisible = false;

  Future<void> _handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      print('taped---');
      final input = emailController.text.trim();
      final password = passwordController.text.trim();

      // ✅ Super Admin check (case-insensitive username)
      if (input.toLowerCase() == "admin" && password == "Pasb@1234") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MenuScreen(isSuperAdmin: true)),
        );
        return;
      }

      // ✅ Normal user check from SQLite
      final users = await UserCreateDbHelper.instance.getUsers();
      print("🧠 All users from DB: ${users.length}");

      UserModel? matchedUser;
      try {
        print("🔍 Checking login for: $input | password: $password");

        for (var user in users) {
          print(
            "📋 User in DB → id:${user.id}, email:${user.email}, phone:${user.phone}, password:${user.password}",
          );
        }

        matchedUser = users.firstWhere(
          (user) =>
              ((user.email?.toLowerCase() == input.toLowerCase()) ||
                  (user.phone == input)) &&
              PasswordUtils.verifyPassword(password, user.password),
        );

        print("✅ Login success for: ${matchedUser.username}");
      } catch (e) {
        print("❌ No matching user found. Error: $e");
        matchedUser = null;
      }

      // ✅ Navigation or error message
      if (matchedUser != null) {
        await SessionManager.saveUserSession(
          name: matchedUser.username,
          email: matchedUser.email ?? "",
          phone: matchedUser.phone,
        );

        print(
          'user data stored ---> ${matchedUser.username} ${matchedUser.email} ${matchedUser.phone} ',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MenuScreen(isSuperAdmin: false),
          ),
        );
      } else {
        ToastMessage.showError(context, "Invalid credentials!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 900,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Left side image
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 400,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.black, width: 4),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            "assets/c0f02f03-59c1-4669-8973-cb0fdc3b17cb.jpg",
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Right side (login form)
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Pakistan Armed Services Board (PASB)",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Secure access to your dashboard",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Email field
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 80,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Enter Email or Phone',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    controller: emailController,
                                    focusNode: _emailFocus,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(_passwordFocus);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email or phone',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email or phone is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password field
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 80,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    controller: passwordController,
                                    focusNode: _passwordFocus,
                                    obscureText: !_isPasswordVisible,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) =>
                                        _handleLogin(context),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Login Button
                            Consumer<AuthProvider>(
                              builder: (context, value, child) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 80,
                                  ),
                                  child: ButtonComponent(
                                    ontap: () => _handleLogin(context),
                                    title: 'Sign In',
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 40),
                            Text(
                              "© ${DateTime.now().year} Pakistan Armed Services Board",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 50),

                            // Footer
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                children: [
                                  const TextSpan(text: "Developed by "),
                                  TextSpan(
                                    text: "Burgeon",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final url = Uri.parse(
                                          "https://burgeon-grp.com",
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                  ),
                                  const TextSpan(text: " - "),
                                  TextSpan(
                                    text: "https://burgeon-grp.com",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final url = Uri.parse(
                                          "https://burgeon-grp.com",
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
