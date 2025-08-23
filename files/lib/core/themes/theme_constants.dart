// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../constants/app_colors.dart';
// import '../constants/app_defaults.dart';
// import '../utils/ui_helper.dart';
//
// class AppTheme {
//   /// Add your custom font name here, which you added in [pubspec.yaml] file
//   static const fontName = 'Montserrat';
//
//   /// A light theme for NewsPro
//   static ThemeData get lightTheme => ThemeData(
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: AppUiHelper.generateMaterialColor(
//             AppColors.primary,
//           ),
//         ),
//
//
//         textTheme: ThemeData.light().textTheme.apply(fontFamily: fontName),
//         scaffoldBackgroundColor: Colors.transparent,
//         cardColor: AppColors.cardColor,
//         canvasColor: AppColors.primary,
//         inputDecorationTheme: InputDecorationTheme(
//           enabledBorder: OutlineInputBorder(
//             borderRadius: AppDefaults.borderRadius,
//             borderSide: BorderSide.none,
//           ),
//
//
//           focusedBorder: OutlineInputBorder(
//             borderRadius: AppDefaults.borderRadius,
//             borderSide: const BorderSide(
//               color: AppColors.primary,
//             ),
//           ),
//           fillColor: AppColors.cardColor,
//           filled: true,
//           floatingLabelBehavior: FloatingLabelBehavior.never,
//         ),
//
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           systemOverlayStyle: SystemUiOverlayStyle(
//             statusBarBrightness: Brightness.light,
//             statusBarIconBrightness: Brightness.dark,
//             systemNavigationBarColor: AppColors.scaffoldBackground,
//             systemNavigationBarIconBrightness: Brightness.dark,
//             statusBarColor:Colors.transparent,
//           ),
//
//
//           iconTheme: IconThemeData(color: Colors.black,),
//           titleTextStyle: TextStyle(
//             color: Colors.black,
//             fontFamily: fontName,
//           ),
//           centerTitle: true,
//         ),
//
//
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.all(AppDefaults.padding),
//             shape: RoundedRectangleBorder(
//               borderRadius: AppDefaults.borderRadius,
//             ),
//           ),
//         ),
//
//         outlinedButtonTheme: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             foregroundColor: AppColors.primary,
//             side: const BorderSide(color: AppColors.primary),
//             padding: const EdgeInsets.all(AppDefaults.padding),
//             shape: RoundedRectangleBorder(
//               borderRadius: AppDefaults.borderRadius,
//             ),
//           ),
//         ),
//
//         tabBarTheme: TabBarTheme(
//           indicator: const UnderlineTabIndicator(
//             borderSide: BorderSide(
//               color: AppColors.primary,
//               width: 2,
//             ),
//           ),
//
//
//           labelPadding: const EdgeInsets.symmetric(
//             horizontal: AppDefaults.padding,
//             vertical: AppDefaults.padding / 1.15,
//           ),
//
//           labelColor: AppColors.primary,
//           unselectedLabelColor: AppColors.cardColorDark.withOpacity(0.5),
//           indicatorSize: TabBarIndicatorSize.label,
//           labelStyle: const TextStyle(
//             fontFamily: fontName,
//             fontWeight: FontWeight.bold,
//           ),
//           unselectedLabelStyle: const TextStyle(fontFamily: fontName),
//         ),
//         checkboxTheme: const CheckboxThemeData(
//           side: BorderSide(
//             color: Colors.transparent,
//           ),
//         ),
//       );
//
//   /// A light theme for NewsPro
//   static ThemeData get darkTheme => ThemeData(
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: AppUiHelper.generateMaterialColor(
//             AppColors.primary,
//           ),
//         ),
//         textTheme: ThemeData.dark().textTheme.apply(
//               fontFamily: fontName,
//               displayColor: Colors.white,
//               bodyColor: Colors.white,
//             ),
//         cardColor: AppColors.cardColorDark,
//         scaffoldBackgroundColor: Colors.transparent,
//         canvasColor: AppColors.cardColorDark,
//         inputDecorationTheme: InputDecorationTheme(
//           enabledBorder: OutlineInputBorder(
//             borderRadius: AppDefaults.borderRadius,
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: AppDefaults.borderRadius,
//             borderSide: const BorderSide(
//               color: AppColors.primary,
//             ),
//           ),
//           fillColor: AppColors.cardColorDark,
//           filled: true,
//           floatingLabelBehavior: FloatingLabelBehavior.never,
//           labelStyle: const TextStyle(color: AppColors.placeholder),
//           iconColor: AppColors.placeholder,
//           hintStyle: const TextStyle(color: AppColors.placeholder),
//         ),
//         iconTheme: const IconThemeData(color: AppColors.primary),
//         listTileTheme: const ListTileThemeData(iconColor: AppColors.primary),
//
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           iconTheme: IconThemeData(
//             color: Colors.black,
//           ),
//           systemOverlayStyle: SystemUiOverlayStyle(
//             statusBarBrightness: Brightness.light,
//             statusBarIconBrightness: Brightness.dark,
//             systemNavigationBarColor: AppColors.scaffoldBackground ,
//             systemNavigationBarIconBrightness: Brightness.dark,
//             statusBarColor: Colors.transparent,
//           ),
//
//           titleTextStyle: TextStyle(
//             color: Colors.black,
//             fontFamily: fontName,
//           ),
//           centerTitle: true,
//         ),
//
//
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.all(AppDefaults.padding),
//             shape: RoundedRectangleBorder(
//               borderRadius: AppDefaults.borderRadius,
//             ),
//           ),
//         ),
//         outlinedButtonTheme: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             foregroundColor: AppColors.primary,
//             side: const BorderSide(color: AppColors.primary),
//             padding: const EdgeInsets.all(AppDefaults.padding),
//             shape: RoundedRectangleBorder(
//               borderRadius: AppDefaults.borderRadius,
//             ),
//           ),
//         ),
//         tabBarTheme: TabBarTheme(
//           indicator: const UnderlineTabIndicator(
//             borderSide: BorderSide(
//               color: AppColors.primary,
//               width: 2,
//             ),
//           ),
//           labelPadding: const EdgeInsets.symmetric(
//             horizontal: AppDefaults.padding,
//             vertical: AppDefaults.padding / 1.15,
//           ),
//           labelColor: AppColors.primary,
//           unselectedLabelColor: AppColors.cardColor.withOpacity(0.5),
//           indicatorSize: TabBarIndicatorSize.label,
//           labelStyle: const TextStyle(
//             fontFamily: fontName,
//             fontWeight: FontWeight.bold,
//           ),
//           unselectedLabelStyle: const TextStyle(fontFamily: fontName),
//         ),
//         checkboxTheme: const CheckboxThemeData(
//           side: BorderSide(
//             color: Colors.transparent,
//           ),
//         ),
//       );
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_defaults.dart';
import '../utils/ui_helper.dart';

class AppTheme {
  /// Add your custom font name here, which you added in [pubspec.yaml] file
  static const fontName = 'Montserrat';
  static const Color kPrimary = Color(0xFFa93ae2);

  /// A light theme for NewsPro
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppUiHelper.generateMaterialColor(
        kPrimary,
      ),
    ),
    primaryColor: kPrimary,
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: fontName, fontSize: 24, fontWeight: FontWeight.bold, color: kPrimary), // Main titles
      displayMedium: TextStyle(fontFamily: fontName, fontSize: 22, fontWeight: FontWeight.bold, color: kPrimary),
      displaySmall: TextStyle(fontFamily: fontName, fontSize: 20, fontWeight: FontWeight.bold, color: kPrimary),
      headlineLarge: TextStyle(fontFamily: fontName, fontSize: 18, fontWeight: FontWeight.bold, color: kPrimary), // Subtitles
      headlineMedium: TextStyle(fontFamily: fontName, fontSize: 16, fontWeight: FontWeight.bold, color: kPrimary),
      headlineSmall: TextStyle(fontFamily: fontName, fontSize: 14, fontWeight: FontWeight.bold, color: kPrimary),
      titleLarge: TextStyle(fontFamily: fontName, fontSize: 16, fontWeight: FontWeight.w500, color: kPrimary), // Details
      titleMedium: TextStyle(fontFamily: fontName, fontSize: 14, fontWeight: FontWeight.w500, color: kPrimary),
      titleSmall: TextStyle(fontFamily: fontName, fontSize: 14, fontWeight: FontWeight.w500, color: kPrimary),
      bodyLarge: TextStyle(fontFamily: fontName, fontSize: 16, color: kPrimary), // Normal text
      bodyMedium: TextStyle(fontFamily: fontName, fontSize: 14, color: kPrimary), // Sub/explanatory text
      bodySmall: TextStyle(fontFamily: fontName, fontSize: 14, color: kPrimary),
      labelLarge: TextStyle(fontFamily: fontName, fontSize: 16, fontWeight: FontWeight.w500, color: kPrimary), // Buttons
      labelMedium: TextStyle(fontFamily: fontName, fontSize: 14, fontWeight: FontWeight.w500, color: kPrimary),
      labelSmall: TextStyle(fontFamily: fontName, fontSize: 14, color: kPrimary),
    ),
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    cardColor: AppColors.cardColor,
    canvasColor: AppColors.cardColor,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDefaults.borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDefaults.borderRadius,
        borderSide: BorderSide(
          color: kPrimary,
        ),
      ),
      fillColor: AppColors.cardColor,
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontFamily: fontName,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(AppDefaults.padding),
        elevation: 4,
        shadowColor: kPrimary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        side: BorderSide(color: kPrimary, width: 2),
        padding: const EdgeInsets.all(AppDefaults.padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    tabBarTheme: TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: kPrimary,
          width: 2,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 1.15,
      ),
      labelColor: kPrimary,
      unselectedLabelColor: AppColors.cardColorDark.withOpacity(0.5),
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontFamily: fontName,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(fontFamily: fontName),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(
        color: AppColors.scaffoldBackgrounDark,
      ),
    ),
  );

  /// A light theme for NewsPro
  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppUiHelper.generateMaterialColor(
        kPrimary,
      ),
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: fontName,
      displayColor: Colors.black,
      bodyColor: Colors.black,
    ),
    cardColor: AppColors.cardColorDark,
    scaffoldBackgroundColor: AppColors.scaffoldBackgrounDark,
    canvasColor: AppColors.cardColorDark,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDefaults.borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDefaults.borderRadius,
        borderSide: BorderSide(
          color: kPrimary,
        ),
      ),
      fillColor: AppColors.cardColorDark,
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: TextStyle(color: AppColors.placeholder),
      iconColor: AppColors.placeholder,
      hintStyle: TextStyle(color: AppColors.placeholder),
    ),
    iconTheme: IconThemeData(color: kPrimary),
    listTileTheme: ListTileThemeData(iconColor: kPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.scaffoldBackgrounDark,
      elevation: 0,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.scaffoldBackgrounDark,
        statusBarColor: AppColors.scaffoldBackgrounDark,
      ),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: fontName,
      ),
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(AppDefaults.padding),
        shape: RoundedRectangleBorder(
          borderRadius: AppDefaults.borderRadius,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        side: BorderSide(color: kPrimary),
        padding: const EdgeInsets.all(AppDefaults.padding),
        shape: RoundedRectangleBorder(
          borderRadius: AppDefaults.borderRadius,
        ),
      ),
    ),
    tabBarTheme: TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: kPrimary,
          width: 2,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 1.15,
      ),
      labelColor: kPrimary,
      unselectedLabelColor: AppColors.cardColor.withOpacity(0.5),
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontFamily: fontName,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(fontFamily: fontName),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(
        color: AppColors.scaffoldBackground,
      ),
    ),
  );
}