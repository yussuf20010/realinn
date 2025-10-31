import 'dart:ui';
import 'package:timeago/timeago.dart' as timeago;

class AppLocales {
  static Locale english = const Locale('en', 'US');
  static Locale arabic = const Locale('ar', 'SA');

  static List<Locale> supportedLocales = [
    english,
    arabic,
  ];

  /// Returns a formatted version of language
  /// if nothing is present than it will pass the locale to a string
  static String formattedLanguageName(Locale locale) {
    if (locale == english) {
      return 'English';
    } else if (locale == arabic) {
      return 'عربي';
    } else {
      return locale.countryCode.toString();
    }
  }

  /// If you want custom messages on time ago (eg. a minute ago, a while ago)
  /// you can modify the below code, otherwise don't modify it unless necesarry
  static void setLocaleMessages() {
    timeago.setLocaleMessages(english.toString(), timeago.EnMessages());
    timeago.setLocaleMessages(arabic.toString(), timeago.ArMessages());
  }
}
