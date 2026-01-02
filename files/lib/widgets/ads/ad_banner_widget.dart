import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/ads_service.dart';
import '../../config/components/network_image.dart';

class AdBannerWidget extends StatelessWidget {
  final StaticAd ad;
  final double? height;
  final double? width;

  const AdBannerWidget({
    Key? key,
    required this.ad,
    this.height,
    this.width,
  }) : super(key: key);

  Future<void> _handleAdTap() async {
    if (ad.linkUrl != null && ad.linkUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(ad.linkUrl!);
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
    if (ad.imageUrl == null || ad.imageUrl!.isEmpty) {
      return SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    
    // Responsive sizing for tablets
    final defaultHeight = isTablet ? 80.h : 90.h;
    final borderRadius = isTablet ? 12.r : 8.r;
    final margin = isTablet ? EdgeInsets.symmetric(vertical: 6.h) : EdgeInsets.symmetric(vertical: 8.h);
    final labelPadding = isTablet 
        ? EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h)
        : EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h);
    final labelFontSize = isTablet ? 8.sp : 9.sp;
    final shadowBlur = isTablet ? 8.0 : 4.0;
    final shadowOffset = isTablet ? 4.0 : 2.0;

    return GestureDetector(
      onTap: _handleAdTap,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? defaultHeight,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isTablet ? 0.12 : 0.1),
              blurRadius: shadowBlur,
              offset: Offset(0, shadowOffset),
              spreadRadius: isTablet ? 1 : 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: NetworkImageWithLoader(
                ad.imageUrl!,
                height: height ?? defaultHeight,
                width: width ?? double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // "Ad" label - better positioned and styled for tablets
            Positioned(
              top: isTablet ? 6.h : 4.h,
              right: isTablet ? 6.w : 4.w,
              child: Container(
                padding: labelPadding,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(isTablet ? 6.r : 4.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: isTablet ? 1 : 0.5,
                  ),
                ),
                child: Text(
                  'ad'.tr().toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: isTablet ? 0.5 : 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

