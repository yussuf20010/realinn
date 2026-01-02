import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/wp_config.dart';
import '../../config/dynamic_config.dart';

class AppColors {
  /* <----------- Colors ------------> */
  /// Primary Color of this App - Uses dynamic color from API
  static Color primary(BuildContext? context) {
    if (context != null) {
      try {
        final dynamicConfig = ProviderScope.containerOf(context, listen: false)
            .read(dynamicConfigProvider);
        return dynamicConfig.primaryColor;
      } catch (e) {
        return WPConfig.navbarColor; // Fallback to constant
      }
    }
    return WPConfig.navbarColor; // Fallback to constant
  }

  // Legacy getter for backward compatibility (uses constant)
  static Color get primaryStatic {
    return WPConfig.navbarColor;
  }

  static const Color primaryImportant = Colors.yellow;

  // Others Color
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFECECEC);

  static const Color placeholder = Color(0xFF8E8E8E);
  static const Color separator = Color(0xFFFAFAFA);
  static const Color transpa = Colors.transparent;

  // Dark

  static const Color scaffoldBackgrounDark =
      Color(0xFF000000); // Dark muted green
  static const Color cardColorDark =
      Color(0xFF210A79); // Slightly lighter than scaffold

  static const Color colorE5D1B2 = Color(0xFFE5D1B2);

  static const colors = [
    Color(0xFFa93ae2), // Base color
    Color(0xFFb84de8), // Slightly lighter shade
    Color(0xFFc760ee), // Medium shade
    Color(0xFFd673f4), // Lighter shade
    Color(0xFFe586fa), // Lightest shade
  ];
}
