import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/wp_config.dart';
import '../models/user.dart' show AuthResponse, User;
import 'token_storage_service.dart';

class AuthService {
  // Sign up (Register)
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

        // Save session cookies
        final cookies = response.headers['set-cookie'] ?? '';
        if (cookies.isNotEmpty) {
          await TokenStorageService.saveCookies(cookies);
        }

        // Save user data if available
        if (authResponse.user != null) {
          await TokenStorageService.saveUser(authResponse.user!);
          await TokenStorageService.saveToken(
              'session_cookie'); // Mark as logged in
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
    required String email,
    required String verificationCode,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final requestBody = {
        'email': email,
        'verification_code': verificationCode,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      };

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
