import 'package:flutter/material.dart';
import 'package:testing_window_app/model/account_model.dart';
import 'package:testing_window_app/sqlite/database_helper.dart';

class AccountProvider extends ChangeNotifier {
  late DatabaseHelper handler;

  void addAccount(String accountholder, String accountName) async {
    var res = await handler.inserAccount(
      AccountJson(
        accHolder: accountholder,
        accName: accountName,
        accStatus: 1,
        accCreatedAt: DateTime.now().toIso8601String(),
      ),
    );
    notifyListeners();
  }
}
