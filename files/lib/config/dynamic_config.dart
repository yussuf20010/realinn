import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/site_settings_controller.dart';
import '../models/site_settings.dart';
import 'wp_config.dart';

final dynamicConfigProvider = Provider<DynamicConfig>((ref) {
  final siteSettingsAsync = ref.watch(siteSettingsProvider);
  return siteSettingsAsync.when(
    data: (siteSettings) => DynamicConfig.fromSiteSettings(siteSettings),
    loading: () => DynamicConfig.loading(),
    error: (e, _) => DynamicConfig.loading(),
  );
});

class DynamicConfig {
  final String? appName;
  final Color primaryColor;
  final String? logoUrl;
  final String? logoTwo;
  final String? favicon;

  DynamicConfig({
    this.appName,
    required this.primaryColor,
    this.logoUrl,
    this.logoTwo,
    this.favicon,
  });

  // Helper method to parse hex color
  static Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return WPConfig.navbarColor; // Fallback to constant
    }
    try {
      // Remove # if present
      String hex = colorHex.replaceAll('#', '');
      // Add # and parse
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return WPConfig.navbarColor; // Fallback to constant
    }
  }

  factory DynamicConfig.fromSiteSettings(SiteSettings siteSettings) {
    return DynamicConfig(
      appName: siteSettings.websiteTitle,
      primaryColor: _parseColor(siteSettings.primaryColor), // Use API color
      logoUrl: siteSettings.logo,
      logoTwo: siteSettings.logoTwo,
      favicon: siteSettings.favicon,
    );
  }

  factory DynamicConfig.loading() {
    return DynamicConfig(
      appName: null,
      primaryColor: WPConfig.navbarColor, // Use constant color while loading
      logoUrl: null,
      logoTwo: null,
      favicon: null,
    );
  }
}
