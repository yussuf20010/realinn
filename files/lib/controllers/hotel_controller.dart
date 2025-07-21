import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';

final hotelProvider = FutureProvider<List<Hotel>>((ref) async {
  final url = 'https://cloud-computing-2d51f-default-rtdb.firebaseio.com/hotels.json';
  final response = await http.get(Uri.parse(url));
  print('Hotel API response: ' + response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    print('Parsed hotel data: ' + data.toString());
    // دعم كلا الهيكلين: مع أو بدون مفتاح hotels
    final hotelsMap = data['hotels'] is Map<String, dynamic>
        ? data['hotels'] as Map<String, dynamic>
        : data;
    final hotels = hotelsMap.entries.map((e) => Hotel.fromJson(e.value, e.key)).toList();
    print('Hotels list length: ' + hotels.length.toString());
    return hotels;
  } else {
    print('Failed to load hotels: ${response.statusCode}');
    throw Exception('Failed to load hotels');
  }
}); 