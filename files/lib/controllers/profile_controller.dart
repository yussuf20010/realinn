import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  final url = 'https://realinn-c99f1-default-rtdb.firebaseio.com/profile.json';
  print('ProfileController: Fetching profile from $url');
  
  final response = await http.get(Uri.parse(url));
  print('ProfileController: Response status code: ${response.statusCode}');
  print('ProfileController: Raw response body: ${response.body}');
  
  if (response.statusCode == 200) {
    final dynamic decoded = json.decode(response.body);
    print('ProfileController: Decoded response: $decoded');
    
    if (decoded == null) {
      print('ProfileController: API returned null response');
      throw Exception('Failed to load profile: API returned null response');
    }
    
    if (decoded is! Map<String, dynamic>) {
      print('ProfileController: Invalid response format. Expected Map<String, dynamic> but got ${decoded.runtimeType}');
      throw Exception('Failed to load profile: Invalid response format');
    }
    
    // Check if the response has the expected structure
    if (decoded.containsKey('status') && decoded.containsKey('data')) {
      if (decoded['status'] == 'success' && decoded['data'] != null) {
        try {
          final profile = ProfileModel.fromJson(decoded['data']);
          print('ProfileController: Successfully parsed profile for ${profile.username}');
          return profile;
        } catch (e, stack) {
          print('ProfileController: Error parsing profile data: $e');
          print('ProfileController: Stack trace: $stack');
          throw Exception('Failed to parse profile data: $e');
        }
      } else {
        print('ProfileController: API returned unsuccessful status or null data');
        throw Exception('Failed to load profile: Invalid response status');
      }
    } else {
      // If the response doesn't have the expected structure, try to parse it directly
      try {
        final profile = ProfileModel.fromJson(decoded);
        print('ProfileController: Successfully parsed profile directly from response for ${profile.username}');
        return profile;
      } catch (e, stack) {
        print('ProfileController: Error parsing profile data directly: $e');
        print('ProfileController: Stack trace: $stack');
        throw Exception('Failed to parse profile data: $e');
      }
    }
  } else {
    print('ProfileController: API request failed with status ${response.statusCode}');
    throw Exception('Failed to load profile: ${response.statusCode}');
  }
}); 