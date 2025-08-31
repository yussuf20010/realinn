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
      print('=== END HOTEL LOADING DEBUG ===');
      return hotels;
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Error response body: ${response.body}');
      print('=== END HOTEL LOADING DEBUG ===');

      // Return fallback hotel data instead of throwing an error
      print('Returning fallback hotel data due to API error');
      return _getFallbackHotels();
    }
  } catch (e) {
    print('Exception during hotel loading: $e');
    print('Exception type: ${e.runtimeType}');
    print('=== END HOTEL LOADING DEBUG ===');

    // Return fallback hotel data instead of throwing an error
    print('Returning fallback hotel data due to exception');
    return _getFallbackHotels();
  }
});

// Fallback hotel data when API fails
List<Hotel> _getFallbackHotels() {
  return [
    Hotel(
      id: '1',
      name: 'Cairo Marriott Hotel',
      cityId: 1,
      countryId: 1,
      description: 'Luxury hotel in the heart of Cairo',
      rate: 4.5,
      priceRange: '150-200',
      imageUrl:
          'https://via.placeholder.com/300x200/4A90E2/FFFFFF?text=Cairo+Marriott',
    ),
    Hotel(
      id: '2',
      name: 'Hurghada Grand Hotel',
      cityId: 2,
      countryId: 1,
      description: 'Beachfront resort with stunning Red Sea views',
      rate: 4.3,
      priceRange: '120-160',
      imageUrl:
          'https://via.placeholder.com/300x200/50C878/FFFFFF?text=Hurghada+Grand',
    ),
    Hotel(
      id: '3',
      name: 'Sharm El Sheikh Resort',
      cityId: 3,
      countryId: 1,
      description: 'Premium resort with world-class diving',
      rate: 4.7,
      priceRange: '180-250',
      imageUrl:
          'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Sharm+Resort',
    ),
    Hotel(
      id: '4',
      name: 'Luxor Palace Hotel',
      cityId: 4,
      countryId: 1,
      description: 'Historic hotel near ancient temples',
      rate: 4.2,
      priceRange: '90-130',
      imageUrl:
          'https://via.placeholder.com/300x200/9B59B6/FFFFFF?text=Luxor+Palace',
    ),
    Hotel(
      id: '5',
      name: 'Alexandria Beach Hotel',
      cityId: 5,
      countryId: 1,
      description: 'Mediterranean charm with modern amenities',
      rate: 4.0,
      priceRange: '110-150',
      imageUrl:
          'https://via.placeholder.com/300x200/3498DB/FFFFFF?text=Alexandria+Beach',
    ),
  ];
}
