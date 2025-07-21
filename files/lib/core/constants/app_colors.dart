import 'package:flutter/material.dart';

import '../../config/wp_config.dart';

class AppColors {
  /* <----------- Colors ------------> */
  /// Primary Color of this App
  static const Color primary = WPConfig.primaryColor;
  static const Color primaryImportant = Colors.yellow;

  // Others Color
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFECECEC);

  static const Color placeholder = Color(0xFF8E8E8E);
  static const Color separator = Color(0xFFFAFAFA);
  static const Color transpa = Colors.transparent;

  // Dark

  static const Color scaffoldBackgrounDark = Color(0xFF000000); // Dark muted green
  static const Color cardColorDark = Color(0xFF210A79); // Slightly lighter than scaffold

  static const Color colorE5D1B2 = Color(0xFFE5D1B2);

  static const colors = [
    Color(0xA2210A79), // Base color
    Color(0xA2C620C4), // Slightly lighter shade
    Color(0xFF8D2FC5), // Medium shade
    Color(0xFFC04BFF), // Lighter shade
    Color(0xFFC582EF), // Lightest shade
  ];

}
