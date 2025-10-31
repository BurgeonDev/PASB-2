import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_window_app/components/toast_message.dart';
import 'package:testing_window_app/viewmodel/password_hash.dart';
import '../../model/user_model.dart';
import '../../sqlite/user_create_db_helper.dart';
import '../../components/textfield_component.dart';
import '../../components/button_component.dart';

class UserCreateScreen extends StatefulWidget {
  const UserCreateScreen({super.key});

  @override
  State<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends State<UserCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? selectedRole;
  String? selectedRank;
  String? selectedProvince;
  String? selectedDirectorate;
  String? selectedDasb;
  String? selectedDistrict;

  // Roles and ranks
  final List<String> roles = [
    "Nation-wide User",
    "Directorate User",
    "DASB User",
    "District User",
  ];

  final List<String> ranks = ["Major", "Colonel", "Captain"];

  // Province data hierarchy
  final Map<String, Map<String, Map<String, List<String>>>> provinceHierarchy =
      {
        "Punjab": {
          "Punjab ASB Dte (C&S)": {
            "Bhakkar": ["Layyah"],
            "Bahawalpur": ["Lodhran"],
            "Bahawalnagar": [],
            "DG Khan": ["Rajanpur"],
            "Faisalabad": [],
            "Gujranwala": ["Hafizabad"],
            "Jhang": [],
            "Kasur": [],
            "Khushab": [],
            "Lahore": [],
            "Mianwali": [],
            "Multan": ["Khanewal (Camp Off)"],
            "Muzaffargarh": [],
            "Okara": [],
            "Rahim Yar Khan": [],
            "Sialkot": ["Narowal (Camp Off)"],
            "Sahiwal": ["Pakpattan"],
            "Sargodha": [],
            "Sheikhupura": [],
            "Toba Tek Singh": [],
            "Vehari": [],
          },
          "Punjab ASB Dte (North)": {
            "Attock": [],
            "Chakwal": ["Talagang (Camp Off)"],
            "Gujrat": ["Mandi Bahauddin (Camp Off)"],
            "Jhelum": [],
            "Rawalpindi": ["Murree"],
            "Islamabad": [],
          },
        },
        "KPK": {
          "KPK ASB Dte": {
            "Abbottabad": ["Haripur (Camp Off)"],
            "Bannu": ["Lakki Marwat (Camp Off)"],
            "Chitral": [],
            "DI Khan": [],
            "Kohat": ["Hangu"],
            "Karak": [],
            "Mardan": [],
            "Mansehra": ["Batgram", "Kohistan"],
            "Malakand": ["Swat", "Shangla Alpuri", "Dir", "Bajaur Agency"],
            "Nowshera": [],
            "Peshawar": ["Charsada (Camp Off)"],
            "Swabi": ["Buner"],
            "Tank": ["South Waziristan Agency"],
          },
        },
        "Sindh": {
          "Sindh ASB Dte": {
            "Badin": [],
            "Hyderabad": ["Dadu", "Thatta"],
            "Karachi": ["East", "West", "South", "Malir"],
            "Larkana": ["Jacobabad"],
            "Mirpurkhas": ["Umerkot", "Thar"],
            "Nawabshah": ["Naushehro Feroz"],
            "Sukkur": ["Ghotki", "Shikarpur", "Khairpur"],
            "Sanghar": [],
          },
        },
        "Balochistan": {
          "Balochistan ASB Dte": {
            "Quetta": [
              "Pishin",
              "Killi Abdullah",
              "Chaghi",
              "Loralai",
              "Musakhel",
              "Barkhan",
              "Zhob",
              "Killasaifullah",
              "Sibi",
              "Ziarat",
              "Kohlu",
              "Dera Bugti",
              "Jafarabad",
              "Nasirabad",
              "Jhal Magsi",
              "Bolan",
            ],
            "Khuzdar": [
              "Kalat",
              "Mastung",
              "Kharan",
              "Panjgoor",
              "Turbat",
              "Gawadar",
              "Lasbella",
              "Awaran",
            ],
          },
        },
        "Gilgit Baltistan": {
          "Gilgit Baltistan ASB Dte": {
            "Gilgit": [
              "Diamer (Chilas)",
              "Astore (Camp Off)",
              "Hunza (Camp Off)",
            ],
            "Skardu": ["Ghanche", "Khaplu (Camp Office)"],
            "Ghizer": [],
          },
        },
        "AJ&K": {
          "AJ&K ASB Dte": {
            "Pallandri": [],
            "Kotli": [],
            "Bagh": [],
            "Rawalakot": [],
            "Muzaffarabad": [],
            "Bhimber": [],
            "Haveli": [],
            "Mirpur": [],
            "Neelum": [],
            "Hattian Bala": [],
          },
        },
      };

  // Reset all values
  void _resetForm() {
    ToastMessage.showSuccess(context, "User created successfully!");
    fullNameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    setState(() {
      selectedRole = null;
      selectedRank = null;
      selectedProvince = null;
      selectedDirectorate = null;
      selectedDasb = null;
      selectedDistrict = null;
    });
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    final existingUserByPhone = await UserCreateDbHelper.instance
        .getUserByPhone(phoneController.text);
    final existingUserByEmail = await UserCreateDbHelper.instance
        .getUserByEmail(emailController.text);

    if (existingUserByPhone != null) {
      ToastMessage.showError(context, "Phone number already exists");
      return;
    }

    if (emailController.text.isNotEmpty && existingUserByEmail != null) {
      ToastMessage.showError(context, "Email already exists");
      return;
    }

    final hashedPassword = PasswordUtils.hashPassword(passwordController.text);
    print('hashedPassword ---> $hashedPassword');
    final user = UserModel(
      username: fullNameController.text,
      phone: phoneController.text,
      email: emailController.text.isEmpty ? null : emailController.text,
      password: hashedPassword,
      role: selectedRole!,
      rank: selectedRank ?? '',
      dateEntry: DateTime.now().toString(),
      dasb: selectedDasb ?? '',
      district: selectedDistrict ?? '',
      directorate: selectedDirectorate ?? '',
      nationWideValue: selectedRole == "Nation-wide User" ? "All Access" : '',
      createdBy: 'Admin',
      createdAt: DateTime.now().toString(),
      updatedBy: '',
      updatedAt: '',
    );

    print('user data ---> ${user.toString()}');
    await UserCreateDbHelper.instance.insertUser(user);
    ToastMessage.showSuccess(context, "User created successfully!");
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    List<String> provinceList = provinceHierarchy.keys.toList();
    List<String> directorateList = selectedProvince == null
        ? []
        : provinceHierarchy[selectedProvince!]!.keys.toList();
    List<String> dasbList =
        (selectedProvince != null && selectedDirectorate != null)
        ? provinceHierarchy[selectedProvince!]![selectedDirectorate!]!.keys
              .toList()
        : [];
    List<String> districtList =
        (selectedProvince != null &&
            selectedDirectorate != null &&
            selectedDasb != null)
        ? provinceHierarchy[selectedProvince!]![selectedDirectorate!]![selectedDasb!]!
        : [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff27ADF5),
        title: Text(
          "Create User Account",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildLabeledField(
                        label: "Full Name *",
                        child: Textfieldcomponent(
                          hinttext: "Enter full name",
                          controller: fullNameController,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabeledField(
                        label: "Phone Number *",
                        child: Textfieldcomponent(
                          hinttext: "Enter phone number",
                          controller: phoneController,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                          type: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _buildLabeledField(
                        label: "Password *",
                        child: Textfieldcomponent(
                          hinttext: "Enter password",
                          controller: passwordController,
                          hidetext: _obscurePassword,
                          surficon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return "Required";
                            if (v.length < 6) return "Min 6 chars";
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabeledField(
                        label: "Confirm Password *",
                        child: Textfieldcomponent(
                          hinttext: "Re-enter password",
                          controller: confirmPasswordController,
                          hidetext: _obscureConfirmPassword,
                          surficon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return "Required";
                            if (v != passwordController.text)
                              return "Passwords do not match";
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                _buildLabeledField(
                  label: "Email (Optional)",
                  child: Textfieldcomponent(
                    hinttext: "Enter email",
                    controller: emailController,
                    validator: (v) {
                      if (v != null &&
                          v.isNotEmpty &&
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return "Invalid email";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  width: 340,
                  child: _buildLabeledDropdown(
                    label: "Rank *",
                    value: selectedRank,
                    items: ranks,
                    hint: "Select Rank",
                    onChanged: (v) => setState(() => selectedRank = v),
                  ),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  width: 340,
                  child: _buildLabeledDropdown(
                    label: "Role *",
                    value: selectedRole,
                    items: roles,
                    hint: "Select Role",
                    onChanged: (v) => setState(() {
                      selectedRole = v;
                      selectedProvince = null;
                      selectedDirectorate = null;
                      selectedDasb = null;
                      selectedDistrict = null;
                    }),
                  ),
                ),

                if (selectedRole != null &&
                    selectedRole != "Nation-wide User") ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 340,
                    child: _buildLabeledDropdown(
                      label: "Province *",
                      value: selectedProvince,
                      items: provinceList,
                      hint: "Select Province",
                      onChanged: (v) => setState(() {
                        selectedProvince = v;
                        selectedDirectorate = null;
                        selectedDasb = null;
                        selectedDistrict = null;
                      }),
                    ),
                  ),
                ],

                if (selectedProvince != null &&
                    selectedRole != "Nation-wide User") ...[
                  const SizedBox(height: 15),
                  if (selectedRole == "Directorate User" ||
                      selectedRole == "DASB User" ||
                      selectedRole == "District User")
                    SizedBox(
                      width: 340,
                      child: _buildLabeledDropdown(
                        label: "Directorate *",
                        value: selectedDirectorate,
                        items: directorateList,
                        hint: "Select Directorate",
                        onChanged: (v) => setState(() {
                          selectedDirectorate = v;
                          selectedDasb = null;
                          selectedDistrict = null;
                        }),
                      ),
                    ),
                ],

                if (selectedDirectorate != null &&
                    (selectedRole == "DASB User" ||
                        selectedRole == "District User")) ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 340,
                    child: _buildLabeledDropdown(
                      label: "DASB *",
                      value: selectedDasb,
                      items: dasbList,
                      hint: "Select DASB",
                      onChanged: (v) => setState(() {
                        selectedDasb = v;
                        selectedDistrict = null;
                      }),
                    ),
                  ),
                ],

                if (selectedDasb != null &&
                    selectedRole == "District User") ...[
                  const SizedBox(height: 15),
                  _buildLabeledDropdown(
                    label: "District (if available)",
                    value: selectedDistrict,
                    items: districtList.isEmpty
                        ? [selectedDasb!]
                        : districtList,
                    hint: "Select District",
                    onChanged: (v) => setState(() => selectedDistrict = v),
                  ),
                ],

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonComponent(
                      title: "Create Account",
                      ontap: _createUser,
                      buttonColor: Colors.green,
                      width: 160,
                    ),
                    const SizedBox(width: 20),
                    ButtonComponent(
                      title: "Reset",
                      ontap: _resetForm,
                      buttonColor: Colors.blue,
                      width: 160,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildLabel(label), child],
    );
  }

  Widget _buildLabeledDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _dropdownDecoration(),
          hint: Text(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  InputDecoration _dropdownDecoration() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  );
}
