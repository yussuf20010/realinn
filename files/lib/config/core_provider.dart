import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/internet/internet_state_provider.dart';
import 'package:path_provider/path_provider.dart';

enum AppState { introNotDone, loggedIn, loggedOut }

final coreAppStateProvider =
    FutureProvider.family<AppState, BuildContext>((ref, context) async {
  ref.read(internetStateProvider);
  Directory appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Initialize Firebase
  await Firebase.initializeApp();
  return AppState.loggedOut;
});
