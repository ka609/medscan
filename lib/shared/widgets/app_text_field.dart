import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;

  final TextInputType? keyboardType;
  final bool obscureText;

  final IconData? prefixIcon;
  final Widget? suffixIcon;

  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool enabled;
  final bool readOnly;

  final int maxLines;
  final int? maxLength;

  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon)
            : null,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? null : '',
      ),
    );
  }
}