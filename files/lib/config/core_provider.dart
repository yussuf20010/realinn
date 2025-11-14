import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/internet/internet_state_provider.dart';
import '../services/token_storage_service.dart';
import 'package:path_provider/path_provider.dart';

enum AppState { introNotDone, loggedIn, loggedOut }

final coreAppStateProvider =
    FutureProvider.family<AppState, BuildContext>((ref, context) async {
  ref.read(internetStateProvider);
  Directory appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Check if user is logged in by checking for token
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
});
