import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/site_settings.dart';
import '../config/wp_config.dart';
import 'http_headers.dart';

final siteSettingsProvider = FutureProvider<SiteSettings>((ref) async {
  final url = WPConfig.siteSettingsApiUrl;
  final headers = await buildAuthHeaders(extra: {
    'Content-Type': 'application/json',
    'x-api-key': WPConfig.siteApiKey,
  });

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final settingsData = data['settings'] ?? {};
      final siteSettings = SiteSettings.fromJson(settingsData);
      print('Site settings loaded successfully: ${siteSettings.websiteTitle}');
      return siteSettings;
    } else {
      print(
          'Failed to load site settings: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load site settings: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading site settings: $e');
    throw Exception('Error loading site settings: $e');
  }
});
