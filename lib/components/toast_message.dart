import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

class ToastMessage {
  // ✅ Success Toast
  static void showSuccess(BuildContext context, String message) {
    MotionToast.success(
      title: const Text(
        "Success!",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      animationType: AnimationType.slideInFromBottom,
      borderRadius: 12,
      barrierColor: Colors.black26,
      dismissable: true,
      toastDuration: const Duration(seconds: 3),
      width: 350,
      height: 70,
    ).show(context);
  }

  // ❌ Error Toast
  static void showError(BuildContext context, String message) {
    MotionToast.error(
      title: const Text(
        "Error!",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      animationType: AnimationType.slideInFromBottom,
      borderRadius: 12,
      barrierColor: Colors.black26,
      dismissable: true,
      toastDuration: const Duration(seconds: 3),
      width: 350,
      height: 70,
    ).show(context);
  }

  // ⚠️ Info Toast
  static void showInfo(BuildContext context, String message) {
    MotionToast.info(
      title: const Text(
        "Info",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      animationType: AnimationType.slideInFromBottom,
      borderRadius: 12,
      barrierColor: Colors.black26,
      dismissable: true,
      toastDuration: const Duration(seconds: 3),
      width: 350,
      height: 70,
    ).show(context);
  }
}
