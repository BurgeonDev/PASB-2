import 'package:flutter/material.dart';
import 'package:testing_window_app/Pages/reports_section/list_of_disabled.dart';
import 'package:testing_window_app/Pages/reports_section/list_of_shuhada.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pensioners Reports"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Shuhada Card
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ListOfShuhada(),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.red.shade100,
                  elevation: 5,
                  child: const ListTile(
                    leading: Icon(Icons.star, color: Colors.red),
                    title: Text(
                      "List of Shuhada",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Disabled Card
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ListOfDisabled(),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.orange.shade100,
                  elevation: 5,
                  child: const ListTile(
                    leading: Icon(Icons.accessible, color: Colors.orange),
                    title: Text(
                      "List of Disabled",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Beneficiaries Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.blue.shade100,
                elevation: 5,
                child: const ListTile(
                  leading: Icon(Icons.people, color: Colors.blue),
                  title: Text(
                    "List of Ben Fund Beneficiaries ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Beneficiaries Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.blue.shade100,
                elevation: 5,
                child: const ListTile(
                  leading: Icon(Icons.people, color: Colors.blue),
                  title: Text(
                    "List of Ben Fund Verification ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Beneficiaries Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.blue.shade100,
                elevation: 5,
                child: const ListTile(
                  leading: Icon(Icons.people, color: Colors.blue),
                  title: Text(
                    "List of Hon Welfare Officers ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Beneficiaries Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.blue.shade100,
                elevation: 5,
                child: const ListTile(
                  leading: Icon(Icons.people, color: Colors.blue),
                  title: Text(
                    "List of Outstanding Pension Case",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Beneficiaries Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.blue.shade100,
                elevation: 5,
                child: const ListTile(
                  leading: Icon(Icons.people, color: Colors.blue),
                  title: Text(
                    "Summary of Verified Record",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Beneficiaries Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.blue.shade100,
                elevation: 5,
                child: const ListTile(
                  leading: Icon(Icons.people, color: Colors.blue),
                  title: Text(
                    "List of Extn Cases Hon Wel Offrs",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
