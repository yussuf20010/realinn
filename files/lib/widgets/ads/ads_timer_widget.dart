import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ads_service.dart';
import 'ad_popup_widget.dart';
import 'global_ad_manager.dart';

class AdsTimerWidget extends ConsumerStatefulWidget {
  final Widget child;
  final String currentPage;

  const AdsTimerWidget({
    Key? key,
    required this.child,
    required this.currentPage,
  }) : super(key: key);

  @override
  ConsumerState<AdsTimerWidget> createState() => _AdsTimerWidgetState();
}

class _AdsTimerWidgetState extends ConsumerState<AdsTimerWidget> {
  Timer? _adsTimer;
  bool _isAdShowing = false;
  int _currentAdIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAdsTimer();
  }

  @override
  void didUpdateWidget(AdsTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer if page changed
    if (oldWidget.currentPage != widget.currentPage) {
      _restartTimer();
    }
  }

  void _startAdsTimer() {
    _adsTimer?.cancel();
    // Popup ads show every 2 minutes (120 seconds)
    _adsTimer = Timer.periodic(Duration(seconds: 120), (timer) {
      if (!_isAdShowing && mounted) {
        _showAd();
      }
    });
  }

  void _restartTimer() {
    _adsTimer?.cancel();
    _startAdsTimer();
  }

  void _showAd() {
    if (!mounted || _isAdShowing) return;

    // Don't show any ads if another ad is already showing
    if (GlobalAdManager().isAnyAdShowing) return;

    // Don't show popup ads on login/register pages
    if (widget.currentPage == 'login' || widget.currentPage == 'register') {
      return;
    }

    // Get all ads for current page (different types)
    final allAds = StaticAd.getAdsForPage(widget.currentPage);
    if (allAds.isEmpty) return;

    // Filter out popup/interstitial ads if we can't show them yet
    final adManager = GlobalAdManager();
    final availableAds = allAds.where((ad) {
      if (ad.type == AdType.popup || ad.type == AdType.interstitial) {
        return adManager.canShowPopupAd();
      }
      return true; // Banner and other ads can always show
    }).toList();

    if (availableAds.isEmpty) return;

    // Randomly select an ad type to show
    final adTypes = availableAds.map((ad) => ad.type).toSet().toList();
    if (adTypes.isEmpty) return;

    // Cycle through different ad types
    final randomType = adTypes[_currentAdIndex % adTypes.length];
    final adsOfType = availableAds.where((ad) => ad.type == randomType).toList();

    if (adsOfType.isEmpty) return;

    // Select first ad of that type (don't change/rotate ads)
    final adToShow = adsOfType[0];

    setState(() {
      _isAdShowing = true;
    });

    // Show popup for popup/interstitial types only
    if (adToShow.type == AdType.popup || adToShow.type == AdType.interstitial) {
      // Check again if we can show popup ad
      if (!adManager.canShowPopupAd()) return;
      
      adManager.markPopupAdShown();
      
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AdPopupWidget(
          ad: adToShow,
          onClose: () {
            if (mounted) {
              Navigator.of(context).pop();
              setState(() {
                _isAdShowing = false;
              });
            }
          },
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isAdShowing = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _adsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
