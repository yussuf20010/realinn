import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'internet_state.dart';

final internetStateProvider =
StateNotifierProvider<IsConnectedNotifier, InternetState>(
        (ref) => IsConnectedNotifier(ref));

class IsConnectedNotifier extends StateNotifier<InternetState> {
  final Ref ref;
  late final StreamSubscription _subscription;

  IsConnectedNotifier(this.ref) : super(InternetState.loading) {
    _init();
  }

  Future<void> _init() async {
    final result = await Connectivity().checkConnectivity();

    if (result.isEmpty || result.contains(ConnectivityResult.none)) {
      state = InternetState.disconnected;
    } else {
      final isConnected =
      await InternetConnectionChecker.createInstance().hasConnection;
      state = isConnected
          ? InternetState.connected
          : InternetState.disconnected;
    }

    _subscription =
        Connectivity().onConnectivityChanged.listen((results) async {
          if (results.contains(ConnectivityResult.none)) {
            state = InternetState.disconnected;
          } else {
            final isConnected =
            await InternetConnectionChecker.createInstance().hasConnection;
            state = isConnected
                ? InternetState.connected
                : InternetState.disconnected;
          }
        });

    ref.onDispose(() {
      _subscription.cancel();
    });
  }
}
