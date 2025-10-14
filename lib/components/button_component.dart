import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final VoidCallback ontap;
  final String title;
  final Color buttonColor;
  final double width;

  const ButtonComponent({
    super.key,
    required this.ontap,
    required this.title,
    this.buttonColor = Colors.blue, // default color
    this.width = double.infinity, // full width by default
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        onPressed: ontap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
