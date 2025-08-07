import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../config/wp_config.dart';

final locationProvider = FutureProvider<LocationResponse>((ref) async {
  final url = WPConfig.hotelsApiUrl; // Using the same API endpoint
  final headers = {
    'Content-Type': 'application/json',
    'x-api-key': WPConfig.siteApiKey,
  };
  
  try {
    print('Fetching locations from: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    print('Response status code: ${response.statusCode}');
    print('Raw response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      
      if (decodedResponse == null) {
        print('API returned null response');
        throw Exception('API returned null response');
      }
      
      if (decodedResponse is! Map<String, dynamic>) {
        print('Invalid response format. Expected Map<String, dynamic> but got ${decodedResponse.runtimeType}');
        throw Exception('Invalid response format');
      }
      
      final locationResponse = LocationResponse.fromJson(decodedResponse);
      
      print('Successfully parsed location data:');
      print('- Countries: ${locationResponse.countries?.length ?? 0}');
      print('- States: ${locationResponse.states?.length ?? 0}');
      print('- Cities: ${locationResponse.cities?.length ?? 0}');
      print('- Hotels: ${locationResponse.hotels?.length ?? 0}');
      
      return locationResponse;
    } else {
      print('Failed to load locations. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
      throw Exception('Failed to load locations: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error loading locations: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Error loading locations: $e');
  }
});

// Legacy provider for backward compatibility
final legacyLocationProvider = FutureProvider<List<LocationModel>>((ref) async {
  final locationResponse = await ref.watch(locationProvider.future);

  // Convert countries to LocationModel format for backward compatibility
  return locationResponse.countries?.map((country) => LocationModel(
    country: country.name,
    numberOfHotels: 0, // This would need to be calculated based on hotels in this country
    image: null,
    hotels: null,
  )).toList() ?? [];
}); 