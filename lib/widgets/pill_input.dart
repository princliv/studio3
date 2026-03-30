import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PillInput extends StatelessWidget {
  const PillInput({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.onChanged,
    this.onToggleVisibility,
    this.keyboardType,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDims.pillInputHeight,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.slate700,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.inter(color: AppColors.slate400),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: const BorderSide(color: AppColors.slate800, width: 1.5),
          ),
          suffixIcon: onToggleVisibility != null
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.slate500, size: 22),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
