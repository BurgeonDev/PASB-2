import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// 🔹 Get full screen width
  double get width => MediaQuery.of(this).size.width;

  /// 🔹 Get full screen height
  double get height => MediaQuery.of(this).size.height;
}
