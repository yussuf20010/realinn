import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import '../../../config/wp_config.dart';
import '../../../controllers/dio/dio_provider.dart';
import '../../../models/member.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRepository(dio);
});

abstract class AuthRepoAbstract {
  /// Login User
  Future<Member?> login({required String email, required String password});

  /// Logout User
  Future<void> logout();

  /// Signup User
  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  /// Send OTP for password reset link
  // Future<bool> sendPasswordResetLink(String email);

  /// Verify OTP
  // Future<bool> verifyOTP({required String otp, required String email});

  /// Set The New Password
  // Future<bool> setPassword({
  //   required String email,
  //   required String newPassword,
  //   required String otp,
  // });

  /// Is User Logged In
  Future<bool> isLoggedIn();

  /// Get Saved user on device
  Future<Member?> getUser();

  /// Delete Saved user on device;
  Future<void> deleteUserData();

  /// Save User Data on device
  Future<void> saveUserData(Member data);

  /// Google Social Login
  // Future<Member?> googleSignIn();

  /// Apple Social Login
  // Future<Member?> appleSignIn();
}
class AuthRepository extends AuthRepoAbstract {
  final Dio dio;
  AuthRepository(this.dio);


  final String _tokenKey = 'auth_token';
  final String _userBoxKey = 'user';
  final String _userKey = '_jiie';

  // Get stored token
  Future<String?> getToken() async {
    try {
      if (!Hive.isBoxOpen(_userBoxKey)) {
        await Hive.openBox(_userBoxKey);
      }
      var box = Hive.box(_userBoxKey);
      final token = box.get(_tokenKey); 
      return token;
    } catch (e) {
      return null;
    }
  }

  // Save token
  Future<void> saveToken(String token) async {
    try {
      if (!Hive.isBoxOpen(_userBoxKey)) {
        await Hive.openBox(_userBoxKey);
      }
      var box = Hive.box(_userBoxKey);
      await box.put(_tokenKey, token);
      print('Token saved successfully: $token');
      
      // Verify the save
      final savedToken = box.get(_tokenKey);
      print('Verified saved token: $savedToken');
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // Delete token
  Future<void> deleteToken() async {
    try {
      if (!Hive.isBoxOpen(_userBoxKey)) {
        await Hive.openBox(_userBoxKey);
      }
      var box = Hive.box(_userBoxKey);
      await box.delete(_tokenKey);
      print('Token deleted successfully');
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<Member?> login({
    required String email,
    required String password,
  }) async {
    String url = '${WPConfig.url}auth/login';
    print('Attempting login for email: $email');

    try {
      final response = await dio.post(
        url,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'apiKey': '${WPConfig.apikey}',
        }),
        data: {
          'email': email,
          'password': password,
        },
      );
      
      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');

      if (response.statusCode == 200) {
        final user = Member.fromServer(response.data['user']);
        final token = response.data['data'];
        
        if (token != null) {
          print('Received token from server: $token');
          await saveToken(token);
          // Verify token was saved
          final savedToken = await getToken();
          print('Verified saved token: $savedToken');
        } else {
          print('No token received in response');
        }
        
        await saveUserData(user);
        return user;
      } else {
        print('Login failed with status code: ${response.statusCode}');
        return null;
      }
    } on Exception catch (e) {
      print('Login exception: $e');
      if(e.toString().contains("401")){
        Fluttertoast.showToast(msg: 'Invalid Credentials');
      }
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await deleteToken();
      await deleteUserData();
    } on Exception catch (_) {}
  }

  @override
  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    String url = '${WPConfig.url}auth/register';
    print('Sign-up started');
    print('POST URL: $url');
    print('Request Data: $firstName, $lastName, $email');

    try {
      final response = await dio.post(
        url,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'apiKey': '${WPConfig.apikey}', // Add API key here
        }),
        data: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 201) {
        print('Sign-up successful');
        return true;
      } else {
        print('Sign-up failed with status code: ${response.statusCode}');
        return false;
      }
    } on Exception catch (e) {
      print('Sign-up exception: $e');
      if (e.toString().contains("422")) {
        Fluttertoast.showToast(msg: 'Email already exists');
      } else {
        Fluttertoast.showToast(msg: 'Oops! Something gone wrong');
      }
      return false;
    }
  }





  /* <----  -----> */ /* <----  -----> */
  /* <-----------------------> 
      USER DATA SAVING [Local]     
  <-----------------------> */

  @override
  Future<Member?> getUser() async {
    var box = Hive.box(_userBoxKey);
    final Map? data = box.get(_userKey);
    if (data != null) {

      final theUser = Member.fromLocal(Map.from(data));
      return theUser;
    } else {
      return null;
    }
  }

  @override
  Future<void> saveUserData(Member data) async {
    var box = Hive.box(_userBoxKey);
    await box.put(_userKey, data.toMap());
  }

  @override
  Future<void> deleteUserData() async {
    var box = Hive.box(_userBoxKey);
    await box.delete(_userKey);
  }

  /// Initializes Users Databases
  Future<void> init() async {
    await Hive.openBox(_userBoxKey);
  }


}
