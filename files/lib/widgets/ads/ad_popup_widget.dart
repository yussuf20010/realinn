import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/ads_service.dart';
import '../../config/components/network_image.dart';
import 'global_ad_manager.dart';

class AdPopupWidget extends StatefulWidget {
  final StaticAd ad;
  final VoidCallback? onClose;

  const AdPopupWidget({
    Key? key,
    required this.ad,
    this.onClose,
  }) : super(key: key);

  @override
  State<AdPopupWidget> createState() => _AdPopupWidgetState();
}

class _AdPopupWidgetState extends State<AdPopupWidget> {
  Timer? _countdownTimer;
  int _remainingSeconds = 5;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Register this ad as showing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        GlobalAdManager().registerAdShowing(context);
      }
    });
    // Allow closing after 1 second
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _canClose = true;
        });
      }
    });
  }

  void _startCountdown() {
    _remainingSeconds = 5;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
            _closeAd();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _closeAd() {
    _countdownTimer?.cancel();
    // Close all ads when close is clicked
    GlobalAdManager().closeAllAds();
    if (mounted && widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    // Unregister this ad
    if (mounted && context.mounted) {
      GlobalAdManager().unregisterAd(context);
    }
    super.dispose();
  }

  Future<void> _handleAdTap() async {
    if (widget.ad.linkUrl != null && widget.ad.linkUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(widget.ad.linkUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Error launching ad URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    final isLandscape = screenSize.width > screenSize.height;

    // Responsive sizing - optimized for tablets
    final maxWidth = isTablet
        ? (isLandscape ? 450.w : 400.w)
        : (isLandscape ? 340.w : 320.w);
    final imageHeight = isTablet
        ? (isLandscape ? 320.h : 450.h)
        : (isLandscape ? 240.h : 380.h);
    final closeButtonSize = isTablet ? 38.w : 32.w;
    final timerSize = isTablet ? 38.w : 32.w;
    final borderRadius = isTablet ? 20.r : 16.r;

    return Dialog(
      backgroundColor: Colors.black54,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32.w : 20.w,
        vertical: isTablet ? 40.h : 24.h,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isTablet ? 0.3 : 0.25),
              blurRadius: isTablet ? 40 : 30,
              offset: Offset(0, isTablet ? 12 : 10),
              spreadRadius: isTablet ? 6 : 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Single full image
              if (widget.ad.imageUrl != null && widget.ad.imageUrl!.isNotEmpty)
                GestureDetector(
                  onTap: _handleAdTap,
                  child: SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: NetworkImageWithLoader(
                      widget.ad.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Gradient overlay at top for better visibility of controls
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Header controls overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // "Ad" label with better styling
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'ad'.tr().toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Close button with timer - floating style
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Timer circle background
                              if (_remainingSeconds > 0)
                                SizedBox(
                                  width: timerSize,
                                  height: timerSize,
                                  child: CircularProgressIndicator(
                                    value: _remainingSeconds / 5,
                                    strokeWidth: 3,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orange[500]!,
                                    ),
                                  ),
                                ),
                              // Close button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _canClose ? _closeAd : null,
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    width: closeButtonSize,
                                    height: closeButtonSize,
                                    padding: EdgeInsets.all(6.w),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: isTablet ? 20.sp : 18.sp,
                                      color: _canClose
                                          ? Colors.grey[800]
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                              // Timer text
                              if (_remainingSeconds > 0 && _canClose)
                                Text(
                                  '$_remainingSeconds',
                                  style: TextStyle(
                                    fontSize: isTablet ? 11.sp : 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
