import 'package:flutter/material.dart';

class AppStyles {
  static const Color mainBlue = Color(0xFF9461c9); // Bright blue for main actions
  static const Color fieldFill = Color(0xFFF6F8FA); // Very light background for input fields
  static const double borderRadius = 16.0;

  static InputDecoration inputDecoration({required String label, required IconData icon, String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: fieldFill,
      prefixIcon: Icon(icon, color: mainBlue),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: mainBlue, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  static ButtonStyle mainButton = ElevatedButton.styleFrom(
    backgroundColor: mainBlue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    elevation: 2,
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    side: const BorderSide(color: mainBlue),
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
} 