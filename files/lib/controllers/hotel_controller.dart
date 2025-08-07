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
  
  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      // Extract hotels from the correct location in the response
      List<dynamic> hotelsList;
      if (data['hotels'] is List) {
        hotelsList = data['hotels'] as List<dynamic>;
      } else if (data['data'] is List) {
        hotelsList = data['data'] as List<dynamic>;
      } else {
        // If it's a map with hotel IDs as keys
        final hotelsMap = data as Map<String, dynamic>;
        hotelsList = hotelsMap.entries.map((e) {
          final hotelData = e.value as Map<String, dynamic>;
          hotelData['id'] = e.key; // Add the ID to the hotel data
          return hotelData;
        }).toList();
      }
      
      final hotels = hotelsList.map((hotelData) {
        if (hotelData is Map<String, dynamic>) {
          final id = hotelData['id']?.toString() ?? '';
          return Hotel.fromJson(hotelData, id);
        } else {
          throw Exception('Invalid hotel data format');
        }
      }).toList();
      
      print('Hotels loaded successfully. Count: ${hotels.length}');
      print('Hotels data: ${hotels.map((h) => h.toJson()).toList()}');
      return hotels;
    } else {
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error loading hotels: $e');
  }
}); 