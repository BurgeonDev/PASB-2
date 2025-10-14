import 'package:flutter/material.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/components/toast_message.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController lanDbController = TextEditingController();
  final TextEditingController internetDbController = TextEditingController();
  final TextEditingController smsGatewayIpController = TextEditingController();
  final TextEditingController smsGatewayKeyController = TextEditingController();

  @override
  void dispose() {
    lanDbController.dispose();
    internetDbController.dispose();
    smsGatewayIpController.dispose();
    smsGatewayKeyController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      ToastMessage.showSuccess(context, 'Settings saved successfully!');
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              validator: (value) =>
                  value!.isEmpty ? "Please enter $label" : null,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Settings"),
        // centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 60),
                // First row (LAN + Internet)
                Row(
                  children: [
                    _buildTextField(
                      label: "LAN Database Server IP",
                      hint: "e.g. 192.168.1.10",
                      controller: lanDbController,
                    ),
                    _buildTextField(
                      label: "Internet Database Server IP",
                      hint: "e.g. 203.0.113.10",
                      controller: internetDbController,
                    ),
                  ],
                ),
                // Second row (SMS IP + SMS Key)
                Row(
                  children: [
                    _buildTextField(
                      label: "SMS Gateway IP",
                      hint: "e.g. 10.0.0.2",
                      controller: smsGatewayIpController,
                    ),
                    _buildTextField(
                      label: "SMS Gateway Key",
                      hint: "Enter your key here",
                      controller: smsGatewayKeyController,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ButtonComponent(
                    title: "Save Settings",
                    ontap: _onSave,
                    buttonColor: Colors.green,
                    width: 200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
