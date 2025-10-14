import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:testing_window_app/components/button_component.dart';
import 'package:testing_window_app/components/textfield_component.dart';
import 'package:testing_window_app/model/account_model.dart';
import 'package:testing_window_app/sqlite/database_helper.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  TextEditingController accountholderController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  late DatabaseHelper handler;
  late Future<List<AccountJson>> accounts = Future.value([]); // initial dummy

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    _initDatabase();
  }

  void _initDatabase() async {
    await handler.init(); // ensure DB is initialized
    setState(() {
      accounts = handler.getAccounts(); // assign after DB ready
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Accounts'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: FutureBuilder<List<AccountJson>>(
        future: accounts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No Accounts Found'));
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index].accHolder),
                  subtitle: Text(items[index].accName),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void addDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Textfieldcomponent(
                  hinttext: 'Account Holder',
                  controller: accountholderController,
                  prefixIcon: Icon(Icons.person),
                  validator: (value) {},
                ),
              ),
              Textfieldcomponent(
                hinttext: 'Account Name',
                controller: accountNameController,
                prefixIcon: Icon(Icons.account_circle_rounded),
                validator: (value) {},
              ),
            ],
          ),
          actions: [
            Center(
              child: ButtonComponent(
                ontap: () {
                  print('Add User tapped');
                  addAccount();
                  // Provider.of<AccountProvider>(
                  //   context,
                  //   listen: false,
                  // ).addAccount(
                  //   accountholderController.text,
                  //   accountNameController.text,
                  // );
                },
                title: 'Add Account',
              ),
            ),
          ],
        );
      },
    );
  }

  void addAccount() async {
    var res = await handler.inserAccount(
      AccountJson(
        accHolder: accountholderController.text,
        accName: accountNameController.text,
        accStatus: 1,
        accCreatedAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}
