import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dynamic_config.dart';

class WPConfig {
  /// The Name of your app
  static const String appName = 'RealInn';

  /// The url of your app, should not inclued any '/' slash or any 'https://' or 'http://'
  /// Otherwise it may break the compaitbility, And your website must be
  /// a wordpress website.
  static const String url = 'https://realinn.b-circles.co';
  static const String siteStorageUrl = 'https://realinn.b-circles.co/storage/' ;
  static const String siteSettingsApiUrl = '$url/api/site-settings';
  static const String hotelsApiUrl = '$url/api/hotels';
  static const String siteApiKey = 'your_secret_api_key';
  /// Primary Color of the App, must be a valid hex code after '0xFF '
  static Color get primaryColor {
    final container = ProviderContainer();
    final dynamicConfig = container.read(dynamicConfigProvider);
    return dynamicConfig.primaryColor ?? const Color(0xFF885ac9);
  }
  static const String apikey = '1234';

  /// fake order state
  static const int orderState = 3;

  /// If we should force user to login everytime they start the app
  static const bool forceUserToLoginEverytime = false;

  /// Newspro Configuration ID from website
  static const int configID = 676;

  /// Deeplinks config
  /// If you are using something like this:
  /// https://newspro.uixxy.com/sample-post/
  /// make this true or else false
  static const bool usingPlainFormatLink = true;

  /* <---- Show Post on notificaiton -----> */
  /// If you want to enable a post dialog when a notification arrives, if
  /// it is false a small Toast will appear on the bottom of the screen, see the
  /// example below
  /// https://drive.google.com/file/d/1Dq2ZyNgXTsnFFqm4m9infbnSn4rb-vTl/view?usp=sharing
  static bool showPostDialogOnNotificaiton = false;

  /// IF you want the popular post plugin to be disabled turn this to "false"
  static bool isPopularPostPluginEnabled = true;

  /* <----------------------->
      Categories
   <-----------------------> */

  /// Show horizonatal Logo in home page or title
  /// You can replace the logo in the asset folder
  /// horizonatal logo width is 136x35
  static bool showLogoInHomePage = true;

  /// IF we should keep the caching of home categories tab caching or not
  /// if this is false, then we will fetch new data and refresh the
  /// list if user changes tab or click on one
  static bool enableHomeTabCache = true;

  /// Blocked Categories ID's which will not appear in UI
  ///
  /// How to find category ID:
  /// https://njengah.com/find-wordpress-category-id/
  static List<int> blockedCategoriesIds = [1];

  static String enArticleCategoryFilterNumber = '0';
  static String arArticleCategoryFilterNumber = '1';
  static String videosCategoryFilterNumber  = '2';

  static String get imageBaseUrl => siteStorageUrl;
}
