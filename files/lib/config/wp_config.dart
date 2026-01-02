import 'package:flutter/material.dart';

class WPConfig {
  static const String appName = 'RealInn';
  static const String url = 'https://realinn.b-circles.co';
  static const String siteStorageUrl = 'https://realinn.b-circles.co/storage/';
  static const String apiBaseUrl = '$url/api';

  // Headers and API key
  static const String siteApiKey = 'your_secret_api_key';
  static Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-KEY': siteApiKey,
      };

  // Build headers with optional Authorization and Cookie
  static Map<String, String> buildHeaders({
    Map<String, String>? extra, 
    String? bearerToken,
    String? cookies,
  }) {
    final headers = <String, String>{...defaultHeaders};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + bearerToken;
    }
    if (cookies != null && cookies.isNotEmpty) {
      headers['Cookie'] = cookies;
    }
    if (extra != null && extra.isNotEmpty) {
      headers.addAll(extra);
    }
    return headers;
  }

  // Core endpoints
  static const String siteSettingsApiUrl = '$apiBaseUrl/site-settings';

  // Hotels
  static const String hotelsApiUrl = '$apiBaseUrl/hotels';
  static const String hotelsSearchApiUrl = '$apiBaseUrl/hotels/search';
  static String hotelDetailsApiUrl({required String slug, required int id}) =>
      '$apiBaseUrl/hotels/$slug/$id';
  static const String hotelStatesApiUrl = '$apiBaseUrl/hotels/states';
  static const String hotelCitiesApiUrl = '$apiBaseUrl/hotels/cities';

  // Service Providers
  static const String serviceProvidersApiUrl = '$apiBaseUrl/service-providers';
  static const String serviceProviderStatesApiUrl =
      '$apiBaseUrl/service-providers/states';
  static const String serviceProviderCitiesApiUrl =
      '$apiBaseUrl/service-providers/cities';
  static String serviceProvidersByCategoryApiUrl(int categoryId) =>
      '$apiBaseUrl/service-providers/$categoryId';
  static String serviceProviderShowByCategoryApiUrl(
          {required int categoryId, required int id}) =>
      '$apiBaseUrl/service-providers/$categoryId/$id';
  static String serviceByIdApiUrl(int id) =>
      '$apiBaseUrl/service-providers/service/$id';
  static String serviceProviderPortfolioApiUrl(int id) =>
      '$apiBaseUrl/service-providers/$id/portfolio';

  // Authentication endpoints
  // Registration
  static const String registerUserApiUrl = '$apiBaseUrl/register/user';
  static const String registerHotelApiUrl = '$apiBaseUrl/register/hotel';
  static const String registerServiceProviderApiUrl =
      '$apiBaseUrl/register/service-provider';
  static const String registerVerifyOtpApiUrl =
      '$apiBaseUrl/register/verify-otp';
  static const String registerResendOtpApiUrl =
      '$apiBaseUrl/register/resend-otp';

  // Legacy endpoints (for backward compatibility)
  static const String userSignupApiUrl = '$apiBaseUrl/user/signup';
  static const String userVerifyApiUrl = '$apiBaseUrl/user/verify-otp';
  static const String userResendVerificationApiUrl =
      '$apiBaseUrl/user/resend-otp';

  // Login & Password
  static const String userLoginApiUrl = '$apiBaseUrl/user/login';
  static const String userForgetPasswordApiUrl =
      '$apiBaseUrl/user/forget-password';
  static const String userResetPasswordApiUrl =
      '$apiBaseUrl/user/reset-password';

  // User endpoints
  static String addHotelToWishlistApiUrl(int hotelId) =>
      '$apiBaseUrl/user/add-wishlist/hotel/$hotelId';
  static String addRoomToWishlistApiUrl(int roomId) =>
      '$apiBaseUrl/user/add-wishlist/room/$roomId';
  static const String getUserBookingsApiUrl = '$apiBaseUrl/user/bookings';

  // Bookings endpoints
  static const String applyCouponApiUrl = '$apiBaseUrl/bookings/apply-coupon';
  static const String createBookingApiUrl = '$apiBaseUrl/bookings';

  // Payment Documents endpoints
  static const String paymentDocumentsApiUrl = '$apiBaseUrl/payment-documents';
  static const String paymentDocumentsUploadApiUrl = '$apiBaseUrl/payment-documents/upload';
  static String paymentDocumentApiUrl(int id) =>
      '$apiBaseUrl/payment-documents/$id';

  // Service Providers endpoints (updated)
  static String serviceProviderDetailsApiUrl(int id) =>
      '$apiBaseUrl/service-providers/$id';
  static String serviceProviderServicesApiUrl(int id) =>
      '$apiBaseUrl/service-providers/$id/services';
  static String serviceProviderReviewsApiUrl(int id) =>
      '$apiBaseUrl/service-providers/$id/reviews';
  static String serviceProviderCheckAvailabilityApiUrl(int id) =>
      '$apiBaseUrl/service-providers/$id/check-availability';

  static Color get primaryColor {
    return navbarColor;
  }

  static const Color navbarColor = Color(0xFFa93ae1);
  static const String apikey = 'your_secret_api_key';
  static const int orderState = 3;
  static const bool forceUserToLoginEverytime = false;
  static const int configID = 676;
  static const bool usingPlainFormatLink = true;
  static bool showPostDialogOnNotificaiton = false;
  static bool isPopularPostPluginEnabled = true;

  static List<int> blockedCategoriesIds = [1];

  static String enArticleCategoryFilterNumber = '0';
  static String arArticleCategoryFilterNumber = '1';
  static String videosCategoryFilterNumber = '2';

  static String get imageBaseUrl => siteStorageUrl;
}
