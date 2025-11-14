import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/wp_config.dart';
import 'token_storage_service.dart';

class FavoritesService {
  /// Add hotel to wishlist
  static Future<Map<String, dynamic>> addHotelToWishlist(int hotelId) async {
    try {
      final headers = await WPConfig.buildHeaders(
        bearerToken: await TokenStorageService.getToken(),
        cookies: await TokenStorageService.getCookies(),
      );

      final response = await http.post(
        Uri.parse(WPConfig.addHotelToWishlistApiUrl(hotelId)),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMsg = errorData['error']?.toString() ??
            errorData['message']?.toString() ??
            'Failed to add hotel to wishlist';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to add hotel to wishlist: ${e.toString()}');
    }
  }

  /// Add room to wishlist
  static Future<Map<String, dynamic>> addRoomToWishlist(int roomId) async {
    try {
      final headers = await WPConfig.buildHeaders(
        bearerToken: await TokenStorageService.getToken(),
        cookies: await TokenStorageService.getCookies(),
      );

      final response = await http.post(
        Uri.parse(WPConfig.addRoomToWishlistApiUrl(roomId)),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMsg = errorData['error']?.toString() ??
            errorData['message']?.toString() ??
            'Failed to add room to wishlist';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to add room to wishlist: ${e.toString()}');
    }
  }
}

