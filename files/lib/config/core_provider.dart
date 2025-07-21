import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/internet/internet_state_provider.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/auth/auth_controller.dart';
import '../core/repositories/auth/auth_repository.dart';
import '../core/repositories/others/notification_local.dart';
import '../core/repositories/others/onboarding_local.dart';
import '../core/repositories/others/search_local.dart';


/// App Initial State
enum AppState { introNotDone, loggedIn, loggedOut }

final coreAppStateProvider =
FutureProvider.family<AppState, BuildContext>((ref, context) async {
  ref.read(internetStateProvider);
  Directory appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  final onboarding = await OnboardingRepository().init();

  ref.read(authRepositoryProvider).init();
  // ref.read(postRepoProvider).init();
  await SearchLocalRepo().init();
  await Firebase.initializeApp();
  ref.read(authController);

  await NotificationsRepository().init();

  /// Handles background notification
  // ignore: use_build_context_synchronously

  // Is user has been introduced to our app
  if (onboarding.isIntroDone()) {
    return AppState.loggedOut;
  } else {
    return AppState.introNotDone;
  }
});
