import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class CountryService {
  // Using REST Countries API - free public API for world countries
  static const String _baseUrl = 'https://restcountries.com/v3.1';

  /// Fetch all world countries with flags and dial codes
  static Future<List<Country>> fetchAllCountries() async {
    try {
      // Fetch from REST Countries API v3.1 (includes flags, idd for dial codes)
      final response = await http.get(
        Uri.parse('$_baseUrl/all?fields=name,cca2,flags,idd'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback: try alternative endpoint
      try {
        return await _fetchCountriesAlternative();
      } catch (e2) {
        throw Exception('Failed to load countries: $e');
      }
    }
  }

  /// Alternative endpoint (REST Countries v2 for dial codes)
  static Future<List<Country>> _fetchCountriesAlternative() async {
    final response = await http.get(
      Uri.parse(
          'https://restcountries.com/v2/all?fields=name,alpha2Code,flags,callingCodes'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => Country.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
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
