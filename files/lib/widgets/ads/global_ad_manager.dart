import 'package:flutter/material.dart';
import 'dart:async';

/// Global Ad Manager to prevent ad stacking and manage all open ads
class GlobalAdManager {
  static final GlobalAdManager _instance = GlobalAdManager._internal();
  factory GlobalAdManager() => _instance;
  GlobalAdManager._internal();

  // Track all open dialogs/ads
  final List<BuildContext> _openAdContexts = [];
  bool _isAnyAdShowing = false;
  DateTime? _lastPopupAdShown;
  Timer? _popupAdTimer;

  /// Check if any ad is currently showing
  bool get isAnyAdShowing => _isAnyAdShowing;

  /// Check if we can show a popup ad (only once every 2 minutes)
  bool canShowPopupAd() {
    if (_lastPopupAdShown == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastPopupAdShown!);
    return difference.inSeconds >= 120; // 2 minutes
  }

  /// Register an ad as showing
  void registerAdShowing(BuildContext context) {
    if (!_openAdContexts.contains(context)) {
      _openAdContexts.add(context);
      _isAnyAdShowing = true;
    }
  }

  /// Unregister an ad when closed
  void unregisterAd(BuildContext context) {
    _openAdContexts.remove(context);
    _isAnyAdShowing = _openAdContexts.isNotEmpty;
  }

  /// Close all open ads
  void closeAllAds() {
    for (final context in List.from(_openAdContexts)) {
      try {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } catch (e) {
        // Context might be invalid, continue
      }
    }
    _openAdContexts.clear();
    _isAnyAdShowing = false;
  }

  /// Mark popup ad as shown
  void markPopupAdShown() {
    _lastPopupAdShown = DateTime.now();
  }

  /// Clear all state (useful for testing or reset)
  void clear() {
    closeAllAds();
    _lastPopupAdShown = null;
    _popupAdTimer?.cancel();
    _popupAdTimer = null;
  }
}

