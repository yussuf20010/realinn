import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dynamic_config.dart';

class WPConfig {
  static const String appName = 'RealInn';
  static const String url = 'https://realinn.b-circles.co';
  static const String siteStorageUrl = 'https://realinn.b-circles.co/storage/';
  static const String siteSettingsApiUrl = '$url/api/site-settings';
  static const String hotelsApiUrl = '$url/api/hotels';
  static const String siteApiKey = 'your_secret_api_key'; // Updated API key
  static Color get primaryColor {
    return navbarColor; // Use constant color as primary color for whole app
  }

  static const Color navbarColor = Color(0xFFa93ae1);
  static const String apikey = 'your_secret_api_key';
  static const int orderState = 3;
  static const bool forceUserToLoginEverytime = false;
  static const int configID = 676;
  static const bool usingPlainFormatLink = true;
  static bool showPostDialogOnNotificaiton = false;
  static bool isPopularPostPluginEnabled = true;

  /// Blocked Categories ID's which will not appear in UI
  ///
  /// How to find category ID:
  /// https://njengah.com/find-wordpress-category-id/
  static List<int> blockedCategoriesIds = [1];

  static String enArticleCategoryFilterNumber = '0';
  static String arArticleCategoryFilterNumber = '1';
  static String videosCategoryFilterNumber = '2';

  static String get imageBaseUrl => siteStorageUrl;
}
