import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/site_settings_controller.dart';
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

  DynamicConfig({
    this.appName,
    required this.primaryColor,
    this.logoUrl,
  });

  factory DynamicConfig.fromSiteSettings(SiteSettings siteSettings) {
    return DynamicConfig(
      appName: siteSettings.websiteTitle,
      primaryColor: WPConfig.navbarColor, // Use constant color
      logoUrl: siteSettings.logo,
    );
  }

  factory DynamicConfig.loading() {
    return DynamicConfig(
      appName: null,
      primaryColor: WPConfig.navbarColor, // Use constant color
      logoUrl: null,
    );
  }
} 