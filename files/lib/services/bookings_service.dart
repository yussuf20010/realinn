import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/wp_config.dart';
import 'token_storage_service.dart';

class BookingsService {
  /// Get user bookings
  /// Returns a list of bookings for the authenticated user
  static Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      final headers = await WPConfig.buildHeaders(
        bearerToken: await TokenStorageService.getToken(),
        cookies: await TokenStorageService.getCookies(),
      );

      final response = await http.get(
        Uri.parse(WPConfig.getUserBookingsApiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // API might return bookings in different formats
        if (data is Map<String, dynamic>) {
          if (data['bookings'] != null) {
            return List<Map<String, dynamic>>.from(
                (data['bookings'] as List).map((e) => e as Map<String, dynamic>));
          } else if (data['data'] != null) {
            return List<Map<String, dynamic>>.from(
                (data['data'] as List).map((e) => e as Map<String, dynamic>));
          }
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(
              data.map((e) => e as Map<String, dynamic>));
        }
        return [];
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMsg = errorData['error']?.toString() ??
            errorData['message']?.toString() ??
            'Failed to fetch bookings';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to fetch bookings: ${e.toString()}');
    }
  }

  /// Apply coupon code
  /// Returns coupon details with discount information
  static Future<Map<String, dynamic>> applyCoupon({
    required int roomId,
    required String couponCode,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      final headers = WPConfig.buildHeaders(
        extra: {'X-API-Key': WPConfig.siteApiKey},
      );

      final body = json.encode({
        'room_id': roomId,
        'coupon_code': couponCode,
        'check_in': checkIn,
        'check_out': checkOut,
      });

      final response = await http.post(
        Uri.parse(WPConfig.applyCouponApiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMsg = errorData['error']?.toString() ??
            errorData['message']?.toString() ??
            'Failed to apply coupon';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to apply coupon: ${e.toString()}');
    }
  }

  /// Create booking
  /// Returns booking details and payment information
  static Future<Map<String, dynamic>> createBooking({
    required int roomId,
    required String checkIn,
    required String checkOut,
    required int guests,
    required String paymentMethod,
    List<int>? additionalServices,
    String? couponCode,
  }) async {
    try {
      final headers = await WPConfig.buildHeaders(
        bearerToken: await TokenStorageService.getToken(),
        cookies: await TokenStorageService.getCookies(),
        extra: {'X-API-Key': WPConfig.siteApiKey},
      );

      final body = <String, dynamic>{
        'room_id': roomId,
        'check_in': checkIn,
        'check_out': checkOut,
        'guests': guests,
        'payment_method': paymentMethod,
      };

      if (additionalServices != null && additionalServices.isNotEmpty) {
        body['additional_services'] = additionalServices;
      }

      if (couponCode != null && couponCode.isNotEmpty) {
        body['coupon_code'] = couponCode;
      }

      final response = await http.post(
        Uri.parse(WPConfig.createBookingApiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMsg = errorData['error']?.toString() ??
            errorData['message']?.toString() ??
            'Failed to create booking';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }
}

