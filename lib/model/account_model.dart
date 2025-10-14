// To parse this JSON data, do
//
//     final account = accountJsonFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

AccountJson accountJsonFromJson(String str) =>
    AccountJson.fromJson(json.decode(str));

String accountJsonToJson(AccountJson data) => json.encode(data.toJson());

class AccountJson {
  final int? accId;
  final String accHolder;
  final String accName;
  final int accStatus;
  final String accCreatedAt;

  AccountJson({
    this.accId,
    required this.accHolder,
    required this.accName,
    required this.accStatus,
    required this.accCreatedAt,
  });

  factory AccountJson.fromJson(Map<String, dynamic> json) => AccountJson(
    accId: json["accId"],
    accHolder: json["accHolder"],
    accName: json["accName"],
    accStatus: json["accStatus"],
    accCreatedAt: json["accCreatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "accId": accId,
    "accHolder": accHolder,
    "accName": accName,
    "accStatus": accStatus,
    "accCreatedAt": accCreatedAt,
  };
}
