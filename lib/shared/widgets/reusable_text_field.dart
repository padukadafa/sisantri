import 'package:flutter/material.dart';

class ReusableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;

  const ReusableTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      textCapitalization: textCapitalization,
      enabled: enabled,
      onTap: onTap,
      readOnly: readOnly,
      onTapOutside: (event) {
        // Unfocus when tapping outside
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
