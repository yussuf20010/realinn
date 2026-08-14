import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class CountryService {
  // Using REST Countries API - free public API for world countries
  static const String _baseUrl = 'https://restcountries.com/v3.1';

  /// Fetch all world countries with flags and dial codes
  static Future<List<Country>> fetchAllCountries() async {
    final List<Map<String, String>> localCountries = [
      {'name': 'Egypt', 'code': 'EG', 'dialCode': '+20', 'flag': '🇪🇬'},
      {'name': 'Saudi Arabia', 'code': 'SA', 'dialCode': '+966', 'flag': '🇸🇦'},
      {'name': 'United Arab Emirates', 'code': 'AE', 'dialCode': '+971', 'flag': '🇦🇪'},
      {'name': 'Jordan', 'code': 'JO', 'dialCode': '+962', 'flag': '🇯🇴'},
      {'name': 'Kuwait', 'code': 'KW', 'dialCode': '+965', 'flag': '🇰🇼'},
      {'name': 'Qatar', 'code': 'QA', 'dialCode': '+974', 'flag': '🇶🇦'},
      {'name': 'Bahrain', 'code': 'BH', 'dialCode': '+973', 'flag': '🇧🇭'},
      {'name': 'Oman', 'code': 'OM', 'dialCode': '+968', 'flag': '🇴🇲'},
      {'name': 'Lebanon', 'code': 'LB', 'dialCode': '+961', 'flag': '🇱🇧'},
      {'name': 'Syria', 'code': 'SY', 'dialCode': '+963', 'flag': '🇸🇾'},
      {'name': 'Iraq', 'code': 'IQ', 'dialCode': '+964', 'flag': '🇮🇶'},
      {'name': 'Palestine', 'code': 'PS', 'dialCode': '+970', 'flag': '🇵🇸'},
      {'name': 'Yemen', 'code': 'YE', 'dialCode': '+967', 'flag': '🇾🇪'},
      {'name': 'Morocco', 'code': 'MA', 'dialCode': '+212', 'flag': '🇲🇦'},
      {'name': 'Algeria', 'code': 'DZ', 'dialCode': '+213', 'flag': '🇩🇿'},
      {'name': 'Tunisia', 'code': 'TN', 'dialCode': '+216', 'flag': '🇹🇳'},
      {'name': 'Libya', 'code': 'LY', 'dialCode': '+218', 'flag': '🇱🇾'},
      {'name': 'Sudan', 'code': 'SD', 'dialCode': '+249', 'flag': '🇸🇩'},
      {'name': 'Turkey', 'code': 'TR', 'dialCode': '+90', 'flag': '🇹🇷'},
      {'name': 'United States', 'code': 'US', 'dialCode': '+1', 'flag': '🇺🇸'},
      {'name': 'United Kingdom', 'code': 'GB', 'dialCode': '+44', 'flag': '🇬🇧'},
      {'name': 'Canada', 'code': 'CA', 'dialCode': '+1', 'flag': '🇨🇦'},
      {'name': 'Australia', 'code': 'AU', 'dialCode': '+61', 'flag': '🇦🇺'},
      {'name': 'Germany', 'code': 'DE', 'dialCode': '+49', 'flag': '🇩🇪'},
      {'name': 'France', 'code': 'FR', 'dialCode': '+33', 'flag': '🇫🇷'},
      {'name': 'Italy', 'code': 'IT', 'dialCode': '+39', 'flag': '🇮🇹'},
      {'name': 'Spain', 'code': 'ES', 'dialCode': '+34', 'flag': '🇪🇸'},
      {'name': 'India', 'code': 'IN', 'dialCode': '+91', 'flag': '🇮🇳'},
      {'name': 'Pakistan', 'code': 'PK', 'dialCode': '+92', 'flag': '🇵🇰'},
      {'name': 'Brazil', 'code': 'BR', 'dialCode': '+55', 'flag': '🇧🇷'},
      {'name': 'Russia', 'code': 'RU', 'dialCode': '+7', 'flag': '🇷🇺'},
      {'name': 'Japan', 'code': 'JP', 'dialCode': '+81', 'flag': '🇯🇵'},
      {'name': 'China', 'code': 'CN', 'dialCode': '+86', 'flag': '🇨🇳'},
      {'name': 'South Korea', 'code': 'KR', 'dialCode': '+82', 'flag': '🇰🇷'},
      {'name': 'Malaysia', 'code': 'MY', 'dialCode': '+60', 'flag': '🇲🇾'},
      {'name': 'Singapore', 'code': 'SG', 'dialCode': '+65', 'flag': '🇸🇬'},
      {'name': 'South Africa', 'code': 'ZA', 'dialCode': '+27', 'flag': '🇿🇦'},
      {'name': 'Nigeria', 'code': 'NG', 'dialCode': '+234', 'flag': '🇳🇬'},
      {'name': 'Kenya', 'code': 'KE', 'dialCode': '+254', 'flag': '🇰🇪'},
    ];

    final countries = localCountries
        .map((data) => Country(
              name: data['name']!,
              code: data['code']!,
              dialCode: data['dialCode']!,
              flag: data['flag']!,
            ))
        .toList();

    countries.sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }

  /// Search countries by name
  static Future<List<Country>> searchCountries(String query) async {
    final allCountries = await fetchAllCountries();
    final lowerQuery = query.toLowerCase();
    return allCountries.where((country) {
      return country.name.toLowerCase().contains(lowerQuery) ||
          country.dialCode.contains(query) ||
          country.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get country by dial code
  static Future<Country?> getCountryByDialCode(String dialCode) async {
    final allCountries = await fetchAllCountries();
    try {
      return allCountries.firstWhere(
        (country) => country.dialCode == dialCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get country by code (ISO 3166-1 alpha-2)
  static Future<Country?> getCountryByCode(String code) async {
    final allCountries = await fetchAllCountries();
    try {
      return allCountries.firstWhere(
        (country) => country.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
