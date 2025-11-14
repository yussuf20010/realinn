import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/wp_config.dart';
import '../models/user.dart' show AuthResponse, User;
import 'token_storage_service.dart';

enum UserType { user, hotel, serviceProvider }

class AuthService {
  // Register as Regular User
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? name,
  }) async {
    try {
      final body = <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      if (name != null && name.isNotEmpty) {
        body['name'] = name;
      }

      print('🔵 REGISTER USER REQUEST:');
      print('URL: ${WPConfig.registerUserApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(WPConfig.registerUserApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      print('🔵 REGISTER USER RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        return data;
      } else {
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Registration failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Register user error: ${e.toString()}');
    }
  }

  // Register as Hotel
  static Future<Map<String, dynamic>> registerHotel({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    required String hotelName,
    String? country,
    String? city,
    String? state,
    String? address,
    String? zipCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'hotel_name': hotelName,
      };
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (country != null && country.isNotEmpty) body['country'] = country;
      if (city != null && city.isNotEmpty) body['city'] = city;
      if (state != null && state.isNotEmpty) body['state'] = state;
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (zipCode != null && zipCode.isNotEmpty) body['zip_code'] = zipCode;

      print('🔵 REGISTER HOTEL REQUEST:');
      print('URL: ${WPConfig.registerHotelApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(WPConfig.registerHotelApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      print('🔵 REGISTER HOTEL RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        return data;
      } else {
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Hotel registration failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Register hotel error: ${e.toString()}');
    }
  }

  // Register as Service Provider
  static Future<Map<String, dynamic>> registerServiceProvider({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? name,
    String? displayName,
    String? tagline,
    String? description,
    String? country,
    String? city,
    int? mainCategoryId,
    List<String>? skills,
    double? minPrice,
    double? maxPrice,
    String? currency,
  }) async {
    try {
      final body = <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (displayName != null && displayName.isNotEmpty)
        body['display_name'] = displayName;
      if (tagline != null && tagline.isNotEmpty) body['tagline'] = tagline;
      if (description != null && description.isNotEmpty)
        body['description'] = description;
      if (country != null && country.isNotEmpty) body['country'] = country;
      if (city != null && city.isNotEmpty) body['city'] = city;
      // Send main_category_id as single integer (NOT category_ids array)
      if (mainCategoryId != null) {
        body['main_category_id'] = mainCategoryId; // Single integer, not array
      }
      if (skills != null && skills.isNotEmpty) body['skills'] = skills;
      if (minPrice != null) body['min_price'] = minPrice;
      if (maxPrice != null) body['max_price'] = maxPrice;
      if (currency != null && currency.isNotEmpty) body['currency'] = currency;

      print('🔵 REGISTER SERVICE PROVIDER REQUEST:');
      print('URL: ${WPConfig.registerServiceProviderApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('🔵 mainCategoryId parameter: $mainCategoryId');
      print('🔵 main_category_id in body: ${body['main_category_id']}');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(WPConfig.registerServiceProviderApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      print('🔵 REGISTER SERVICE PROVIDER RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        return data;
      } else {
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Service provider registration failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Register service provider error: ${e.toString()}');
    }
  }

  // Verify OTP (new endpoint)
  static Future<AuthResponse> verifyOtp({
    int? userId,
    int? vendorId,
    required String otpCode,
    required String userType, // 'user', 'hotel', 'service_provider'
  }) async {
    try {
      final body = <String, dynamic>{
        'otp_code': otpCode,
        'user_type': userType,
      };
      if (userId != null) {
        body['user_id'] = userId;
      }
      if (vendorId != null) {
        body['vendor_id'] = vendorId;
      }

      print('🔵 VERIFY OTP REQUEST:');
      print('URL: ${WPConfig.registerVerifyOtpApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(WPConfig.registerVerifyOtpApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      print('🔵 VERIFY OTP RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);

        // Save token if provided
        if (data['token'] != null) {
          await TokenStorageService.saveToken(data['token'].toString());
        }

        // Save user type
        if (userType.isNotEmpty) {
          await TokenStorageService.saveUserType(userType);
        }

        // Save user if provided
        if (authResponse.user != null) {
          await TokenStorageService.saveUser(authResponse.user!);
        }

        return authResponse;
      } else {
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'OTP verification failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Verify OTP error: ${e.toString()}');
    }
  }

  // Resend OTP (new endpoint)
  static Future<Map<String, dynamic>> resendOtp({
    int? userId,
    required String userType,
  }) async {
    try {
      final body = <String, dynamic>{
        'user_type': userType,
      };
      if (userId != null) {
        body['user_id'] = userId;
      }

      print('🔵 RESEND OTP REQUEST:');
      print('URL: ${WPConfig.registerResendOtpApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(WPConfig.registerResendOtpApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      print('🔵 RESEND OTP RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return data;
      } else {
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Resend OTP failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Resend OTP error: ${e.toString()}');
    }
  }

  // Legacy Sign up (Register) - kept for backward compatibility
  static Future<AuthResponse> signup({
    required String username,
    required String email,
    required String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final body = <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }

      print('🔵 SIGNUP REQUEST:');
      print('URL: ${WPConfig.userSignupApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(WPConfig.userSignupApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      // Print full response
      print('🔵 SIGNUP RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('Parsed Data: $data');
      print('---');

      if (response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else {
        // Extract error message from response
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Signup failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Signup error: ${e.toString()}');
    }
  }

  // Login (session cookie based)
  static Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final bool looksLikeEmail = username.contains('@');
      final Map<String, dynamic> requestBody = {
        'password': password,
      };
      if (looksLikeEmail) {
        // Send as email, and also include username for backends that accept either
        requestBody['email'] = username;
        requestBody['username'] = username;
      } else {
        requestBody['username'] = username;
      }

      print('🔵 LOGIN REQUEST:');
      print('URL: ${WPConfig.userLoginApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode(requestBody)}');

      final client = http.Client();
      final request = http.Request(
        'POST',
        Uri.parse(WPConfig.userLoginApiUrl),
      );

      request.headers.addAll(WPConfig.defaultHeaders);
      request.body = json.encode(requestBody);

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> data = json.decode(response.body);

      // Extract cookies from response headers for session management
      final cookies = response.headers['set-cookie'] ?? '';

      // Print full response
      print('🔵 LOGIN RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Cookies: $cookies');
      print('Body (Raw): ${response.body}');
      print('Parsed Data: $data');
      print('---');

      client.close();

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);

        // Save token if provided
        if (data['token'] != null) {
          await TokenStorageService.saveToken(data['token'].toString());
        }

        // Save session cookies
        final cookies = response.headers['set-cookie'] ?? '';
        if (cookies.isNotEmpty) {
          await TokenStorageService.saveCookies(cookies);
        }

        // Save user data if available
        if (authResponse.user != null) {
          await TokenStorageService.saveUser(authResponse.user!);
          // Mark as logged in if token wasn't provided
          if (data['token'] == null) {
            await TokenStorageService.saveToken('session_cookie');
          }
        }

        return authResponse;
      } else {
        // Extract error message from response
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Login failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final requestBody = {'email': email};

      print('🔵 FORGOT PASSWORD REQUEST:');
      print('URL: ${WPConfig.userForgetPasswordApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(WPConfig.userForgetPasswordApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(requestBody),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      // Print full response
      print('🔵 FORGOT PASSWORD RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('Parsed Data: $data');
      print('---');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // New API returns reset_token, old API might return verification_code
        return data;
      } else {
        // Extract error message from response
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Forgot password failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Forgot password error: ${e.toString()}');
    }
  }

  // Resend Verification Code (must send user_id)
  static Future<Map<String, dynamic>> resendVerificationCode({
    required int userId,
    String? email,
  }) async {
    try {
      print('🔵 RESEND VERIFICATION REQUEST (GET):');
      final qp = <String, String>{'user_id': userId.toString()};
      if (email != null && email.isNotEmpty) {
        qp['email'] = email;
      }
      final uri = Uri.parse(WPConfig.userResendVerificationApiUrl)
          .replace(queryParameters: qp);
      print('URL: $uri');
      print('Headers: {Accept: application/json}');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      // Print full response
      print('🔵 RESEND VERIFICATION RESPONSE (GET):');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('---');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        String errorMsg =
            'Resend verification failed (status ${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> data = json.decode(response.body);
            errorMsg = data['error']?.toString() ??
                data['message']?.toString() ??
                data['errors']?.toString() ??
                errorMsg;
          } catch (_) {}
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Resend verification error: ${e.toString()}');
    }
  }

  // Verify Email / OTP (supports both legacy and new payloads)
  static Future<AuthResponse> verifyEmail({
    int? userId,
    String? otpCode,
    String? email,
    String? verificationCode,
  }) async {
    try {
      Map<String, dynamic> requestBody;
      if (userId != null && otpCode != null) {
        requestBody = {
          'user_id': userId,
          'otp_code': otpCode,
        };
      } else {
        requestBody = {
          'email': email,
          'verification_code': verificationCode,
        };
      }

      print('🔵 VERIFY EMAIL REQUEST:');
      print('URL: ${WPConfig.userVerifyApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(WPConfig.userVerifyApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(requestBody),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      // Print full response
      print('🔵 VERIFY EMAIL RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('Parsed Data: $data');
      print('---');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);

        // Persist session if server sets cookies upon verification
        final cookies = response.headers['set-cookie'] ?? '';
        if (cookies.isNotEmpty) {
          await TokenStorageService.saveCookies(cookies);
        }

        // Persist user and mark logged in if user is returned
        if (authResponse.user != null) {
          await TokenStorageService.saveUser(authResponse.user!);
          await TokenStorageService.saveToken('session_cookie');
        }

        return authResponse;
      } else {
        // Extract error message from response
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Verification failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Verify error: ${e.toString()}');
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    String? resetToken,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final requestBody = {
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      };
      if (resetToken != null && resetToken.isNotEmpty) {
        requestBody['reset_token'] = resetToken;
      }

      print('🔵 RESET PASSWORD REQUEST:');
      print('URL: ${WPConfig.userResetPasswordApiUrl}');
      print('Headers: ${WPConfig.defaultHeaders}');
      print('Request Body: ${json.encode({
            ...requestBody,
            'new_password': '***',
            'new_password_confirmation': '***'
          })}'); // Hide password in logs

      final response = await http.post(
        Uri.parse(WPConfig.userResetPasswordApiUrl),
        headers: WPConfig.defaultHeaders,
        body: json.encode(requestBody),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      // Print full response
      print('🔵 RESET PASSWORD RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('Parsed Data: $data');
      print('---');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        // Extract error message from response
        final errorMsg = data['error']?.toString() ??
            data['message']?.toString() ??
            data['errors']?.toString() ??
            'Reset password failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Reset password error: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> logout() async {
    await TokenStorageService.clearAuth();
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    return await TokenStorageService.getUser();
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    return await TokenStorageService.isLoggedIn();
  }
}
