import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../config/wp_config.dart';

final hotelProvider = FutureProvider<List<Hotel>>((ref) async {
  final url = WPConfig.hotelsApiUrl;
  final headers = {
    'Content-Type': 'application/json',
    'x-api-key': WPConfig.siteApiKey,
  };
  
  print('=== HOTEL LOADING DEBUG ===');
  print('API URL: $url'); 
  print('API Key: ${WPConfig.siteApiKey}');
  print('Headers: $headers');

  try {
    print('Making HTTP request to: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    
    print('Response status code: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body length: ${response.body.length}');
    print('Response body preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      print('Parsed JSON data keys: ${data.keys.toList()}');
      
      // Extract hotels from the correct location in the response
      List<dynamic> hotelsList;
      if (data['hotels'] is List) {
        hotelsList = data['hotels'] as List<dynamic>;
        print('Found hotels in data["hotels"]: ${hotelsList.length}');
      } else if (data['data'] is List) {
        hotelsList = data['data'] as List<dynamic>;
        print('Found hotels in data["data"]: ${hotelsList.length}');
      } else {
        // If it's a map with hotel IDs as keys
        final hotelsMap = data as Map<String, dynamic>;
        hotelsList = hotelsMap.entries.map((e) {
          final hotelData = e.value as Map<String, dynamic>;
          hotelData['id'] = e.key; // Add the ID to the hotel data
          return hotelData;
        }).toList();
        print('Found hotels in data map: ${hotelsList.length}');
      }
      
      print('Processing ${hotelsList.length} hotels');
      
      final hotels = hotelsList.map((hotelData) {
        if (hotelData is Map<String, dynamic>) {
          final id = hotelData['id']?.toString() ?? '';
          print('Processing hotel with ID: $id, data: $hotelData');
          try {
            return Hotel.fromJson(hotelData, id);
          } catch (e, stackTrace) {
            print('Error creating hotel from JSON: $e');
            print('Stack trace: $stackTrace');
            print('Hotel data: $hotelData');
            rethrow;
          }
        } else {
          print('Invalid hotel data format: $hotelData');
          throw Exception('Invalid hotel data format');
        }
      }).toList();
      
      print('Successfully parsed ${hotels.length} hotels');
      print('Hotels loaded successfully. Count: ${hotels.length}');
      print('Hotels data: ${hotels.map((h) => h.toJson()).toList()}');
      print('=== END HOTEL LOADING DEBUG ===');
      return hotels;
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Error response body: ${response.body}');
      print('=== END HOTEL LOADING DEBUG ===');
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception during hotel loading: $e');
    print('Exception type: ${e.runtimeType}');
    print('=== END HOTEL LOADING DEBUG ===');
    throw Exception('Error loading hotels: $e');
  }
}); 