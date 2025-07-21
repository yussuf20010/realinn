import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/location.dart';

final locationProvider = FutureProvider<List<LocationModel>>((ref) async {
  try {
    final url = 'https://cloud-computing-2d51f-default-rtdb.firebaseio.com/countries.json';
    print('Fetching locations from: $url');
    
    final response = await http.get(Uri.parse(url));
    print('Response status code: ${response.statusCode}');
    print('Raw response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final dynamic decodedResponse = json.decode(response.body);
      
      if (decodedResponse == null) {
        print('API returned null response');
        throw Exception('API returned null response');
      }
      
      if (decodedResponse is! Map<String, dynamic>) {
        print('Invalid response format. Expected Map<String, dynamic> but got ${decodedResponse.runtimeType}');
        throw Exception('Invalid response format');
      }
      
      if (!decodedResponse.containsKey('countries')) {
        print('Response missing "countries" key. Available keys: ${decodedResponse.keys.join(', ')}');
        throw Exception('Response missing "countries" key');
      }
      
      final countriesList = decodedResponse['countries'];
      if (countriesList is! List) {
        print('Invalid countries data. Expected List but got ${countriesList.runtimeType}');
        throw Exception('Invalid countries data format');
      }
      
      final countries = countriesList
          .map((country) => LocationModel.fromJson(country))
          .toList();
      
      print('Successfully parsed ${countries.length} countries:');
      for (var country in countries) {
        print('- ${country.country} (${country.numberOfHotels} hotels)');
      }
      
      return countries;
    } else {
      print('Failed to load locations. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
      throw Exception('Failed to load locations: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error loading locations: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Failed to load locations: $e');
  }
}); 