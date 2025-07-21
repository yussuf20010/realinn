import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../../../config/wp_config.dart';
import '../../core/repositories/auth/auth_repository.dart';
import '../../models/member.dart';

final userControllerProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<Member?>>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<AsyncValue<Member?>> {
  final Ref ref;
  late final AuthRepository _authRepository;

  UserNotifier(this.ref) : super(const AsyncValue.loading()) {
    _authRepository = AuthRepository(Dio());
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      state = const AsyncValue.loading();
      final token = await _authRepository.getToken();
      
      if (token == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final response = await http.get(
        Uri.parse('${WPConfig.url}user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'apiKey': '${WPConfig.apikey}',
        },
      );

      print('Profile API Response Status: ${response.statusCode}');
      print('Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final userData = data['data'];
          final member = Member.fromJson(userData);
          state = AsyncValue.data(member);
        } else {
          state = AsyncValue.error(
            data['message'] ?? 'Failed to fetch user profile',
            StackTrace.current,
          );
        }
      } else {
        final errorData = json.decode(response.body);
        state = AsyncValue.error(
          errorData['message'] ?? 'Failed to fetch user profile',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      print('Error fetching user profile: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshToken() async {
    try {
      // Just fetch the user profile with the current token
      await _fetchUserProfile();
    } catch (e, stackTrace) {
      print('Error refreshing token: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshUserProfile() async {
    await _fetchUserProfile();
  }
} 