import 'package:flutter/material.dart';
import 'package:e_masjid/config/constants.dart';

class CustomInputDecoration {
  static InputDecoration getDecoration({
    required String hintText,
    required IconData icon,
    String? errorText,
    Color? fillColor,
    Color? iconColor,
    Color? borderColor,
    double borderRadius = 12.0,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(
        icon,
        color: iconColor ?? kPrimaryColor.withOpacity(0.7),
      ),
      filled: true,
      fillColor: fillColor ?? Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: borderColor ?? kPrimaryColor,
          width: 1.5,
        ),
      ),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 13),
    );
  }
} 