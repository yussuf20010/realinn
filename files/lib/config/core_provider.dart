import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/internet/internet_state_provider.dart';
import '../services/token_storage_service.dart';
import 'package:path_provider/path_provider.dart';

enum AppState { introNotDone, loggedIn, loggedOut }

final coreAppStateProvider = FutureProvider<AppState>((ref) async {
  try {
    ref.read(internetStateProvider);
  } catch (e) {
    debugPrint('Internet state init error: $e');
  }

  try {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  // Initialize Firebase safely so a Firebase config/platform error never blocks app launch
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init error (continuing launch): $e');
  }

  // Check if user is logged in by checking for token
  try {
    final token = await TokenStorageService.getToken();
    final isLoggedIn = await TokenStorageService.isLoggedIn();

    // Only consider logged in if both token exists and isLoggedIn flag is true
    if (token != null && token.isNotEmpty && isLoggedIn) {
      return AppState.loggedIn;
    } else {
      // If token is missing but flag says logged in, clear it (inconsistent state)
      if (isLoggedIn && (token == null || token.isEmpty)) {
        await TokenStorageService.clearAuth();
      }
      return AppState.loggedOut;
    }
  } catch (e) {
    debugPrint('Token storage init error: $e');
    return AppState.loggedOut;
  }
});
