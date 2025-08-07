import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/site_settings_controller.dart';
import '../models/site_settings.dart';

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
  final Color? primaryColor;
  final String? logoUrl;

  DynamicConfig({
    this.appName,
    this.primaryColor,
    this.logoUrl,
  });

  factory DynamicConfig.fromSiteSettings(SiteSettings siteSettings) {
    Color? primaryColor;
    if (siteSettings.primaryColor != null && siteSettings.primaryColor!.isNotEmpty) {
      try {
        String colorStr = siteSettings.primaryColor!;
        if (!colorStr.startsWith('#')) {
          colorStr = '#$colorStr';
        }
        primaryColor = Color(int.parse(colorStr.replaceFirst('#', '0xff')));
      } catch (e) {
        print('Error parsing primary color: $e');
      }
    }
    return DynamicConfig(
      appName: siteSettings.websiteTitle,
      primaryColor: primaryColor,
      logoUrl: siteSettings.logo,
    );
  }

  factory DynamicConfig.loading() {
    return DynamicConfig(
      appName: null,
      primaryColor: null,
      logoUrl: null,
    );
  }
} 