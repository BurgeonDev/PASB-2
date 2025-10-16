import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Textfieldcomponent extends StatefulWidget {
  final VoidCallback? onTap;
  final String hinttext;
  final FormFieldValidator<String>? validator;
  final TextEditingController controller;
  final Widget? surficon;
  final bool? hidetext;
  final FocusNode? focus;
  final TextInputType? type;
  final Color? backgroundColor;
  final bool alwaysShowSuffix;
  final Color? borderColor;
  final bool? isEditable;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onSubmitted; // ✅ properly declared

  const Textfieldcomponent({
    super.key,
    required this.hinttext,
    required this.controller,
    required this.validator,
    this.borderColor,
    this.surficon,
    this.focus,
    this.prefixIcon,
    this.hidetext = false,
    this.type,
    this.backgroundColor,
    this.isEditable = true,
    this.alwaysShowSuffix = false,
    this.onTap,
    this.inputFormatters,
    this.onSubmitted, // ✅
  });

  @override
  State<Textfieldcomponent> createState() => _TextfieldcomponentState();
}

class _TextfieldcomponentState extends State<Textfieldcomponent> {
  bool showSuffix = false;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();

    // ✅ Use a named listener and check `mounted`
    _listener = () {
      final hasText = widget.controller.text.isNotEmpty;
      if (mounted && hasText != showSuffix) {
        setState(() {
          showSuffix = hasText;
        });
      }
    };

    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    // ✅ Properly remove listener
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: TextFormField(
        keyboardType: widget.type,
        inputFormatters: widget.inputFormatters,
        focusNode: widget.focus,
        validator: widget.validator,
        cursorColor: Colors.black,
        controller: widget.controller,
        obscureText: widget.hidetext ?? false,
        readOnly: !(widget.isEditable ?? true),
        onTap: widget.onTap,
        onFieldSubmitted: widget.onSubmitted, // ✅ added
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.backgroundColor ?? Colors.white,
          suffixIcon: widget.alwaysShowSuffix
              ? widget.surficon
              : (showSuffix ? widget.surficon : null),
          prefixIcon: widget.prefixIcon,

          // ✅ Make long hints wrap or fade safely
          hintText: widget.hinttext,
          hintMaxLines: 1, // ensures single-line display
          hintStyle: const TextStyle(
            overflow: TextOverflow.ellipsis, // prevents overflow
            fontWeight: FontWeight.w400,
            color: Color(0xff6E6E6E),
            fontSize: 16,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          errorStyle: const TextStyle(
            fontSize: 12,
            height: 1.3,
            color: Color(0xffCC3537),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.borderColor ?? const Color(0xffF3E7E2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffF3E7E2)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffCC3537)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffCC3537)),
          ),
        ),
      ),
    );
  }
}
