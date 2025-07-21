import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/auth/auth_repository.dart';
import '../../core/routes/app_routes.dart';
import '../../models/member.dart';
import 'auth_state.dart';

final authController = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepo);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.repository) : super(AuthLoading()) {
    _init();
  }

  final AuthRepository repository;

  _init() async {
    try {
      Member? theUser = await repository.getUser();
      state = AuthLoggedIn(theUser!);
        } catch (e) {
      print('Error initializing auth: $e');
      state = AuthGuestLoggedIn();
    }
  }

  /// Login User
  Future<String?> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final member = await repository.login(email: email, password: password);
      if (member != null) {
        state = AuthLoggedIn(member);
        if (mounted) Navigator.pushNamed(context, AppRoutes.loginAnimation);
        return null;
      } else {
        return 'Invalid Credentials';
      }
    } catch (e) {
      print('Login error: $e');
      return 'An error occurred during login';
    }
  }


  /// signup User
  Future<bool> signup({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required BuildContext context,
  }) async {

    final isCreated = await repository.signUp(
      firstName: firstname,
      lastName: lastname,
      email: email,
      password: password,
    );

    if (isCreated == true) {
      /// Login With the new details.
      // ignore: use_build_context_synchronously
      await login(email: email, password: password, context: context);
      return true;
    }
    else {
      // Fluttertoast.showToast(msg: 'Invalid Credentials');
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await repository.logout();
      state = AuthGuestLoggedIn();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.loginIntro, (v) => false);
      }
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Future<String?> sendResetLinkToEmail(String email) async {
  //   bool isValid = await repository.sendPasswordResetLink(email);
  //   if (isValid) {
  //     return null;
  //   } else {
  //     return 'The email is not registered';
  //   }
  // }

  // Future<bool> validateOTP({required String otp, required String email}) async {
  //   return await repository.verifyOTP(otp: otp, email: email);
  // }

  // Future<bool> resetPassword({
  //   required String newPassword,
  //   required String email,
  //   required String otp,
  // }) async {
  //   bool changed = await repository.setPassword(
  //     email: email,
  //     newPassword: newPassword,
  //     otp: otp,
  //   );
  //   return changed;
  // }
}
