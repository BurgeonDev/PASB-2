import 'package:flutter/material.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/components/toast_message.dart';
import 'package:testing_window_app/utils/responsive)extensionts.dart';

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
        padding: EdgeInsets.symmetric(
          horizontal: context.width * 0.008,
          vertical: context.height * 0.01,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: context.width * 0.012, // Responsive text size
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: context.height * 0.008),
            TextFormField(
              controller: controller,
              validator: (value) =>
                  value!.isEmpty ? "Please enter $label" : null,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.width * 0.012,
                  vertical: context.height * 0.018,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.width * 0.006),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(context.width * 0.006),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(context.width * 0.006),
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
    // 🔹 Adjust max width based on screen size
    double maxContainerWidth = context.width > 1200 ? context.width * 0.6 : 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxContainerWidth),
          padding: EdgeInsets.all(context.width * 0.02),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: context.height * 0.06),
                // First row (LAN + Internet)
                LayoutBuilder(
                  builder: (context, constraints) {
                    // 🔹 If screen is narrow, stack fields vertically
                    bool isNarrow = constraints.maxWidth < 700;
                    return isNarrow
                        ? Column(
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
                          )
                        : Row(
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
                          );
                  },
                ),
                // Second row (SMS IP + SMS Key)
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isNarrow = constraints.maxWidth < 700;
                    return isNarrow
                        ? Column(
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
                          )
                        : Row(
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
                          );
                  },
                ),
                SizedBox(height: context.height * 0.04),
                Center(
                  child: ButtonComponent(
                    title: "Save Settings",
                    ontap: _onSave,
                    buttonColor: Colors.green,
                    width: context.width * 0.15, // responsive button width
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
